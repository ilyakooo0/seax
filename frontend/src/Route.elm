module Route exposing (..)

import Url.Builder as Builder
import Url.Parser exposing ((</>), (<?>), Parser, map, oneOf, s, string, top)
import Url.Parser.Query as Query


type Route
    = SearchRoute
    | ResultsRoute String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map ResultsRoute (s "search" </> string)
        , map SearchRoute top
        ]


printer : Route -> String
printer route =
    case route of
        SearchRoute ->
            Builder.absolute [] []

        ResultsRoute query ->
            Builder.absolute [ "search", query ] []
