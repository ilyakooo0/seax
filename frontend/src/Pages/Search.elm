port module Pages.Search exposing (Model, init, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Heroicons.Outline
import Html.Events
import Json.Decode as JD
import Svg.Attributes
import Ur
import Ur.Cmd
import Ur.Run
import Ur.Sub


url : String
url =
    "http://localhost:8080"


type alias Model =
    { ship : Maybe String, search : String }


type Msg
    = Noop
    | GotShipName String
    | UpdateSearch String
    | Search String


main : Ur.Run.Program Model Msg
main =
    Ur.Run.application
        { init =
            \_ _ ->
                ( { ship = Nothing
                  , search = ""
                  }
                , Cmd.batch
                    [ Ur.logIn url "lidlut-tabwed-pillex-ridrup"
                        |> Cmd.map (always Noop)
                    , Ur.getShipName url |> Cmd.map (result (always Noop) GotShipName)

                    -- , Ur.scry
                    --     { url = url
                    --     , agent = "journal"
                    --     , path = [ "entries", "all" ]
                    --     , error = Noop
                    --     , success =
                    --         D.cell D.ignore
                    --             (D.cell (D.const D.cord "jrnl")
                    --                 (D.list (D.cell D.bigint D.cord))
                    --             )
                    --             |> D.map (\( (), ( (), listings ) ) -> GotListings listings)
                    --     }
                    ]
                    |> Ur.Cmd.cmd
                )
        , update = update
        , view = \model -> { title = "%seax", body = [ view model |> layout [] ] }
        , subscriptions = always Sub.none
        , createEventSource = createEventSource
        , urbitSubscriptions = always Ur.Sub.none

        -- \{ entries, shipName } ->
        --     case ( entries, shipName ) of
        --         ( Just _, Just ship ) ->
        --             Ur.Sub.subscribe
        --                 { ship = ship
        --                 , app = "journal"
        --                 , path = [ "updates" ]
        --                 , deconstructor = decodeJournalUpdate |> D.map GotUpdate
        --                 }
        --         _ ->
        --             Ur.Sub.none
        , onEventSourceMsg = onEventSourceMessage
        , onUrlChange = \_ -> Noop
        , onUrlRequest = \_ -> Noop
        , urbitUrl = \_ -> url
        }


view : Model -> Element Msg
view model =
    column [ centerX, centerY ]
        [ el [ centerX, Font.size 67, Font.heavy ] (text "%seax")
        , row [ padding 16, spacing 8 ]
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
            ( model, Ur.Cmd.none )


result : (a -> c) -> (b -> c) -> Result a b -> c
result f g res =
    case res of
        Ok b ->
            g b

        Err a ->
            f a


port createEventSource : String -> Cmd msg


port onEventSourceMessage : (JD.Value -> msg) -> Sub msg
