module Pages.Home_ exposing (view)

import Html
import View exposing (View)
import Html.Attributes


view : View msg
view =
    { title = "Mini Tools"
    , body = 
        [ Html.h1 [] [ Html.text "Mini Tools" ]
        , Html.ul []
            [ Html.li [] [ Html.a [ Html.Attributes.href "/lottery" ] [ Html.text "Lottery" ] ]
            ]
        ]
    }
