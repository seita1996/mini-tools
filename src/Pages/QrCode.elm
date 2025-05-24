module Pages.QrCode exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.QrCode exposing (Params)
import Html exposing (Html, button, canvas, div, h2, text, textarea)
import Html.Attributes exposing (id, placeholder, rows, style, value)
import Html.Events exposing (onClick, onInput)
import Page
import Request
import Shared
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.advanced
        { init = init
        , update = update
        , view = view shared
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { inputText : String
    , hasGenerated : Bool
    }


init : ( Model, Effect Msg )
init =
    ( { inputText = ""
      , hasGenerated = False
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UpdateInputText String
    | GenerateQRCode


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UpdateInputText text ->
            ( { model | inputText = text }, Effect.none )

        GenerateQRCode ->
            if String.trim model.inputText == "" then
                ( model, Effect.none )
            else
                ( { model | hasGenerated = True }
                , Effect.fromShared (Shared.GenerateQRCode { text = model.inputText, size = 256 })
                )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ model =
    { title = "QR Code Generator"
    , body =
        UI.layout
            [ UI.h1 "QR Code Generator"
            , div [ style "max-width" "600px", style "margin" "0 auto" ]
                [ div [ style "margin-bottom" "20px" ]
                    [ text "Enter text to generate QR code:"
                    , textarea
                        [ placeholder "Enter text here..."
                        , value model.inputText
                        , onInput UpdateInputText
                        , rows 4
                        , style "width" "100%"
                        , style "margin-top" "10px"
                        , style "padding" "10px"
                        , style "border" "1px solid #ccc"
                        , style "border-radius" "4px"
                        , style "font-family" "inherit"
                        , style "font-size" "14px"
                        ]
                        []
                    ]
                , div [ style "margin-bottom" "20px" ]
                    [ button
                        [ onClick GenerateQRCode
                        , style "background-color" "#007bff"
                        , style "color" "white"
                        , style "border" "none"
                        , style "padding" "10px 20px"
                        , style "border-radius" "4px"
                        , style "cursor" "pointer"
                        , style "font-size" "16px"
                        ]
                        [ text "Generate QR Code" ]
                    ]
                , if model.hasGenerated then
                    div [ style "text-align" "center" ]
                        [ h2 [] [ text "Generated QR Code:" ]
                        , canvas
                            [ id "qr-canvas"
                            , style "border" "1px solid #ddd"
                            , style "border-radius" "4px"
                            ]
                            []
                        ]
                  else
                    div [] []
                ]
            ]
    }
