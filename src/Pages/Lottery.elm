module Pages.Lottery exposing (view)

import View exposing (View)
import Html


view : View msg
view =
    { title = "Lottery | Mini Tools"
    , body = 
        [ Html.h1 [] [ Html.text "Lottery" ]
        ]
    }