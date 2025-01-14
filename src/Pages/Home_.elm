module Pages.Home_ exposing (view)

import Html
import UI
import View exposing (View)


view : View msg
view =
    { title = "Mini Tools"
    , body =
        UI.layout
            [ Html.h1 [] [ Html.text "Mini Tools" ]
            , Html.p [] [ Html.text "Mini useful tools." ]
            ]
    }