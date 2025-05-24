port module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Json.Decode as Json
import Request exposing (Request)


-- Port for QR code generation (defined in Main.elm)
port generateQRCodePort : { text : String, size : Int } -> Cmd msg


type alias Flags =
    Json.Value


type alias Model =
    { counter : Int
    }


type Msg
    = Increment
    | Decrement
    | StartLottery
    | GenerateQRCode { text : String, size : Int }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ _ =
    ( { counter = 0 }, Cmd.none )


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
            , Cmd.none
            )
        StartLottery ->
            ( model, Cmd.none )
        
        GenerateQRCode data ->
            ( model, generateQRCodePort data )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none