port module Main exposing (main)

import Animator
import Browser.Events exposing (onAnimationFrameDelta)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Element.Keyed as Keyed
import Html exposing (Html, hr)
import Html.Attributes
import Html.Parser
import Html.String
import Html.String
import Html.Styled.Attributes exposing (css)
import Html.Styled.Attributes exposing (css)
import Html.Events exposing (on)
import Json.Decode as JD
import List
import List.Extra
import Set exposing (Set)
import String.Extra exposing (stripTags)
import Time exposing (Posix)
import Ur
import Ur.Cmd
import Ur.Deconstructor as D
import Ur.Jam exposing (isSig)
import Ur.Run
import Ur.Sub
import Ur.Types exposing (Noun(..))
import Url
import ElmEscapeHtml
import Json.Encode
import Hash

url : String
url =
    "http://localhost:8080"


type SearchEngineState
    = Loading
    | Failed
    | Completed


deconstructSearchEngineState : D.Deconstructor SearchEngineState
deconstructSearchEngineState =
    D.oneOf
        [ D.const D.cord "loading" |> D.map (\_ -> Loading)
        , D.const D.cord "failed" |> D.map (\_ -> Failed)
        , D.const D.cord "completed" |> D.map (\_ -> Completed)
        ]


type alias Model =
    { ship : Maybe String
    , search : String
    , initiatedSearch : Maybe String
    , searchResults : List SearchResult
    , resultTimelines : Dict String ( Animator.Timeline Int, Animator.Timeline Bool )
    , engines : List ( String, SearchEngineState )
    , selectedEngines : Set String
    }


type alias SearchResult =
    { title : String
    , link : String
    , engines : Set String
    }

type Msg
    = Noop
    | GotShipName String
    | UpdateSearch String
    | Search String
    | UpdateSearchResults (List SearchResult) (List ( String, SearchEngineState ))
    | OpenResult String
    | Tick Posix
    | ToggleSearchEngine String


main : Ur.Run.Program Model Msg
main =
    Ur.Run.document
        { init =
            ( { ship = Nothing
              , search = ""
              , initiatedSearch = Nothing
              , searchResults = []
              , resultTimelines = Dict.empty
              , engines = []
              , selectedEngines = Set.empty
              }
            , Cmd.batch
                [ Ur.logIn url "lidlut-tabwed-pillex-ridrup"
                    |> Cmd.map (always Noop)
                , Ur.getShipName url |> Cmd.map (result (always Noop) GotShipName)
                ]
                |> Ur.Cmd.cmd
            )
        , update = update
        , view =
            \model ->
                { title = "%seax"
                , body =
                    [ view model
                        |> layout
                            [ Font.family
                                [ Font.typeface "monospace"
                                , Font.typeface "system-ui"
                                , Font.typeface "-apple-system"
                                , Font.typeface "BlinkMacSystemFont"
                                , Font.typeface "Segoe UI"
                                , Font.typeface "Roboto"
                                , Font.typeface "Helvetica"
                                , Font.typeface "Arial"
                                , Font.sansSerif
                                ]
                            , clipX
                        ]
                    ]
                }
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
                                D.cell
                                    (D.list (D.cell D.cord deconstructSearchEngineState))
                                    (D.list (D.cell (D.list D.cord) (D.cell D.cord D.cord)))
                                    |> D.map
                                        (\( engines, results ) ->
                                            UpdateSearchResults
                                                (List.map
                                                    (\( resultEngines, ( title, link ) ) ->
                                                        { engines = Set.fromList resultEngines, title = title, link = link }
                                                    )
                                                    results
                                                )
                                                engines
                                        )
                            }

                    _ ->
                        Ur.Sub.none
        , onEventSourceMsg = onEventSourceMessage
        , urbitUrl = \_ -> url
        }


logoView : List (Attribute Msg) -> Element Msg
logoView attributes =
    Element.image (List.append [ Html.Attributes.id "tilt" |> htmlAttribute ] attributes)
        { src = "assets/img/logo.png", description = "%seax logo" }

noSearchResultsView : Element Msg
noSearchResultsView = Element.el
        [ Html.Attributes.style "padding" "1em" |> htmlAttribute
        , width (px 500)
        , Font.size 15
        , Html.Attributes.class "wavy" |> htmlAttribute
        ]
        (Element.text """No results found... :) 
We'll try and find you something. 
Just come back later.""")

subtleLinkView : String -> String -> Element Msg
subtleLinkView text href =
    Element.el
        [ Font.size 15
        , pointer
        , mouseOver
            [ Font.color (rgb 0.1 0.7 0.7)
            ]
        ]
        (Element.html (Html.a [ Html.Attributes.href href ] [ Html.text text ]))

aboutView : Element Msg
aboutView = row [ centerX, padding 10, spacing 10]
                [ subtleLinkView "[About]" "https://vagos.github.io/seax"
                , subtleLinkView "[Code]" "https://github.com/ilyakooo0/seax"
                ]


titleEmoji : String -> String
titleEmoji title = 
    let maxUnicode = 0x1F3F0
        minUnicode = 0x1F300
    in title |> Hash.fromString 
             |> Hash.toString 
             |> String.toInt 
             |> Maybe.withDefault 0 
             |> (\x -> ((modBy (maxUnicode - minUnicode) x) + minUnicode))
             |> Char.fromCode
             |> String.fromChar 
             |> (\x -> x ++ " ")


view : Model -> Element Msg
view model =
    case model.initiatedSearch of
        Nothing ->
            column [ centerX, centerY, padding 8, spacing 16 ]
                [ logoView [ centerX, width (px 510), height (px 161) ]
                , searchView model
                , aboutView
                ]

        Just _ ->
            column [ width fill, spacing 16 ]
                [ column [ spacing 16, width (minimum 0 fill), padding 8]
                    [ row [] [ logoView [height (px 40)], searchView model |> el [] ]
                    , row [ spacing 8, paddingEach { top = 16, bottom = 16, left = 0, right = 0 } ]
                    (if List.isEmpty model.engines then
                        []
                    else
                        [ text "Sources: "
                        , model.engines
                            |> List.filter (\( _, state ) -> state /= Failed)
                            |> List.map
                                (\( name, state ) ->
                                    text ("%" ++ name)
                                        |> el
                                            (Font.bold
                                                :: (if Set.isEmpty model.selectedEngines then
                                                        []

                                                    else if Set.member name model.selectedEngines then
                                                        []

                                                    else
                                                        [ Font.color (rgb 0.8 0.8 0.8)
                                                        ]
                                                   )
                                                ++ (case state of
                                                        Loading ->
                                                            [ Html.Attributes.class "shimmer" |> htmlAttribute
                                                            ]

                                                        Completed ->
                                                            [ mouseOver
                                                                [ Font.color (rgb 0.6 0.6 0.6)
                                                                ]
                                                            , pointer
                                                            , Events.onClick (ToggleSearchEngine name)
                                                            ]

                                                        Failed ->
                                                            []
                                                   )
                                            )
                                )
                            |> wrappedRow
                                [ spacing 8
                                , width fill
                                ]
                        ]
                        )
                    ]
                , (if List.isEmpty model.searchResults then
                    noSearchResultsView
                else
                Keyed.column [ width (minimum 0 fill), padding 8 ]
                    (model.searchResults
                        |> List.filter
                            (\{ engines } ->
                                if Set.isEmpty model.selectedEngines then
                                    True

                                else
                                    Set.intersect engines model.selectedEngines |> Set.isEmpty |> not
                            )
                        |> List.map
                            (\{ title, link } ->
                                ( link
                                , column
                                    [ spacing 4
                                    , width (minimum 0 fill)
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
                                            (\i -> toFloat i * 0 |> Animator.at)
                                            |> String.fromFloat
                                         )
                                            ++ "px"
                                        )
                                        |> htmlAttribute
                                    , Html.Attributes.style "margin-bottom" "1em" |> htmlAttribute
                                    , Html.Attributes.style "padding" "0.5em" |> htmlAttribute
                                    , Html.Attributes.class "result" |> htmlAttribute
                                    ]
                                    [ (Element.html 
                                        (Html.a
                                            [ Html.Attributes.href link
                                            , Html.Attributes.class "result-title" 
                                            , Html.Attributes.target "_blank"
                                            ]
                                            [ Html.text
                                            (Maybe.withDefault "" 
                                            (Url.percentDecode 
                                            (ElmEscapeHtml.unescape 
                                            (stripTags 
                                            ((titleEmoji title) ++ title)
                                            ))))
                                            ]
                                        )
                                       )
                                    , text link
                                        |> el
                                            [ Font.color (rgb 0.7 0.7 0.7)
                                            , Html.Attributes.class "result-link" |> htmlAttribute
                                            ]
                                    ]
                                )
                            )
                    ))
                , Element.html (Html.hr [Html.Attributes.style "width" "95%"] [])
                , aboutView
                ]


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (Html.Events.on "keyup"
            (JD.field "key" JD.string
                |> JD.andThen
                    (\key ->
                        if key == "Enter" then
                            JD.succeed msg

                        else
                            JD.fail "Not the enter key"
                    )
            )
        )


searchView : { a | search : String } -> Element Msg
searchView model =
    row [ spacing 8 ]
        [ Input.text 
        [ Html.Attributes.class "shadow" |> htmlAttribute, width (px 400)
        , onEnter (Search model.search)
        ]
            { onChange = UpdateSearch
            , placeholder = Nothing
            , text = model.search
            , label = Input.labelHidden "search"
            }
        , Input.button [ height fill ]
            { label =
                text "search"
                    |> el
                        [ Html.Attributes.class "search" |> htmlAttribute
                        , Border.width 2
                        , padding 6
                        , Font.size 29
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

        UpdateSearchResults results engines ->
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
            ( { model
                | resultTimelines = foo
                , searchResults = results
                , engines = engines
              }
            , Ur.Cmd.none
            )

        OpenResult url_ ->
            ( model, Ur.Cmd.none )

        Tick time ->
            ( Animator.update time (animator model) model, Ur.Cmd.none )

        ToggleSearchEngine name ->
            if Set.member name model.selectedEngines then
                ( { model | selectedEngines = Set.remove name model.selectedEngines }, Ur.Cmd.none )

            else
                ( { model | selectedEngines = Set.insert name model.selectedEngines }, Ur.Cmd.none )


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


listsHaveElementsInCommon : List comparable -> List comparable -> Bool
listsHaveElementsInCommon a b =
    Set.intersect (Set.fromList a) (Set.fromList b) |> Set.isEmpty |> not


port createEventSource : String -> Cmd msg


port onEventSourceMessage : (JD.Value -> msg) -> Sub msg
