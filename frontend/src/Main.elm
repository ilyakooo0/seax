port module Main exposing (main)

import Animator
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Keyed as Keyed
import Heroicons.Outline
import Html.Attributes
import Html.Events
import Json.Decode as JD
import List.Extra
import Svg.Attributes exposing (opacity)
import Time exposing (Posix)
import Ur
import Ur.Cmd
import Ur.Deconstructor as D
import Ur.Run
import Ur.Sub


url : String
url =
    "http://localhost:8080"


type alias Model =
    { ship : Maybe String
    , search : String
    , initiatedSearch : Maybe String
    , searchResults : List SearchResult
    , resultTimelines : Dict String ( Animator.Timeline Int, Animator.Timeline Bool )
    }


type alias SearchResult =
    { title : String
    , link : String
    }


type Msg
    = Noop
    | GotShipName String
    | UpdateSearch String
    | Search String
    | UpdateSearchResults (List SearchResult)
    | OpenResult String
    | Tick Posix


main : Ur.Run.Program Model Msg
main =
    Ur.Run.document
        { init =
            ( { ship = Nothing
              , search = ""
              , initiatedSearch = Nothing
              , searchResults = []
              , resultTimelines = Dict.empty
              }
            , Cmd.batch
                [ Ur.logIn url "lidlut-tabwed-pillex-ridrup"
                    |> Cmd.map (always Noop)
                , Ur.getShipName url |> Cmd.map (result (always Noop) GotShipName)
                ]
                |> Ur.Cmd.cmd
            )
        , update = update
        , view = \model -> { title = "%seax", body = [ view model |> layout [] ] }
        , subscriptions = \model -> Animator.toSubscription Tick model (animator model)
        , createEventSource = createEventSource
        , urbitSubscriptions =
            \{ initiatedSearch, ship } ->
                case ( initiatedSearch, ship ) of
                    ( Just query, Just ship_ ) ->
                        Ur.Sub.sink
                            { app = "seax"
                            , path = [ "search", query ]
                            , ship = ship_
                            , deconstructor =
                                D.list (D.cell D.cord D.cord)
                                    |> D.map
                                        (List.map
                                            (\( title, link ) ->
                                                { title = title, link = link }
                                            )
                                            >> UpdateSearchResults
                                        )
                            }

                    _ ->
                        Ur.Sub.none
        , onEventSourceMsg = onEventSourceMessage
        , urbitUrl = \_ -> url
        }


view : Model -> Element Msg
view model =
    case model.initiatedSearch of
        Nothing ->
            column [ centerX, centerY, padding 8, spacing 16 ]
                [ el [ centerX, Font.size 67, Font.heavy ] (text "%seax")
                , searchView model
                ]

        Just query ->
            column [ width fill, padding 8, spacing 16 ]
                [ searchView model
                , Keyed.column [ width fill ]
                    (model.searchResults
                        |> List.map
                            (\{ title, link } ->
                                ( link
                                , column
                                    [ spacing 4
                                    , width fill
                                    , pointer
                                    , alpha
                                        (Animator.move
                                            (Dict.get link model.resultTimelines
                                                |> Maybe.map Tuple.second
                                                |> Maybe.withDefault (Animator.init False)
                                            )
                                            (\x ->
                                                if x then
                                                    Animator.at 1

                                                else
                                                    Animator.at 0
                                            )
                                        )
                                    , Html.Attributes.style "top"
                                        ((Animator.move
                                            (Dict.get link model.resultTimelines
                                                |> Maybe.map Tuple.first
                                                |> Maybe.withDefault (Animator.init 0)
                                            )
                                            (\i -> toFloat i * 47 |> Animator.at)
                                            |> String.fromFloat
                                         )
                                            ++ "px"
                                        )
                                        |> htmlAttribute
                                    , Html.Attributes.style "position" "absolute" |> htmlAttribute
                                    ]
                                    [ [ text title ]
                                        |> paragraph
                                            [ Font.size 16
                                            , width fill
                                            , Html.Attributes.style "text-overflow" "ellipsis" |> htmlAttribute
                                            ]
                                    , [ text link ]
                                        |> paragraph
                                            [ Font.size 12
                                            , Html.Attributes.style "text-overflow" "ellipsis" |> htmlAttribute
                                            , width fill
                                            , Font.color (rgb 0.7 0.7 0.7)
                                            ]
                                    ]
                                )
                            )
                    )
                ]


searchView : { a | search : String } -> Element Msg
searchView model =
    row [ spacing 8 ]
        [ Input.text []
            { onChange = UpdateSearch
            , placeholder = Nothing
            , text = model.search
            , label = Input.labelHidden "search"
            }
        , Input.button [ height fill ]
            { label =
                text "search"
                    |> el
                        [ Border.width 4
                        , padding 4
                        , Font.size 29
                        , Font.bold
                        , Border.color (rgb 0 0 0)
                        , Background.color (rgb 0 0 0)
                        , Font.color (rgb 1 1 1)
                        , mouseOver
                            [ Font.color (rgb 0 0 0)
                            , Background.color (rgb 1 1 1)
                            ]
                        ]
            , onPress = Just (Search model.search)
            }
        ]


update : Msg -> Model -> ( Model, Ur.Cmd.Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Ur.Cmd.none )

        GotShipName ship ->
            ( { model | ship = Just ship }, Ur.Cmd.none )

        UpdateSearch search ->
            ( { model | search = search }, Ur.Cmd.none )

        Search query ->
            ( { model | initiatedSearch = Just query }, Ur.Cmd.none )

        UpdateSearchResults results ->
            let
                foo =
                    List.Extra.zip (List.range 0 (List.length results - 1)) results
                        |> List.map
                            (\( index, result_ ) ->
                                ( result_.link
                                , case Dict.get result_.link model.resultTimelines of
                                    Just timeline ->
                                        timeline |> Tuple.mapFirst (Animator.go Animator.slowly index)

                                    Nothing ->
                                        ( Animator.init index, Animator.init False |> Animator.go Animator.slowly True )
                                )
                            )
                        |> Dict.fromList
            in
            ( { model | resultTimelines = foo, searchResults = results }, Ur.Cmd.none )

        OpenResult url_ ->
            ( model, Ur.Cmd.none )

        Tick time ->
            ( Animator.update time (animator model) model, Ur.Cmd.none )


animator : Model -> Animator.Animator Model
animator model =
    List.foldl
        (\key anim ->
            anim
                |> Animator.watchingWith
                    (\m -> Dict.get key m.resultTimelines |> Maybe.map Tuple.first |> Maybe.withDefault (Animator.init 0))
                    (\index m ->
                        { m | resultTimelines = m.resultTimelines |> Dict.update key (Maybe.map (\( _, x ) -> ( index, x ))) }
                    )
                    (always False)
                |> Animator.watchingWith
                    (\m -> Dict.get key m.resultTimelines |> Maybe.map Tuple.second |> Maybe.withDefault (Animator.init False))
                    (\shown m ->
                        { m | resultTimelines = m.resultTimelines |> Dict.update key (Maybe.map (\( x, _ ) -> ( x, shown ))) }
                    )
                    (always False)
         -- |> Animator.watching
        )
        Animator.animator
        (Dict.keys model.resultTimelines)


result : (a -> c) -> (b -> c) -> Result a b -> c
result f g res =
    case res of
        Ok b ->
            g b

        Err a ->
            f a


port createEventSource : String -> Cmd msg


port onEventSourceMessage : (JD.Value -> msg) -> Sub msg
