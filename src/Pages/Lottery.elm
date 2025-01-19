module Pages.Lottery exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.Lottery exposing (Params)
import Html exposing (button, div, h2, input, text, textarea)
import Page
import Request
import Shared
import UI
import View exposing (View)
import Html.Attributes exposing (placeholder)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput)
import Html.Events exposing (onClick)
import Time exposing (Posix)
import Random
import Random.List


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
    , numWinners : String
    , results : List String
    , error : Maybe String
    , currentSeed : Random.Seed
    }


init : ( Model, Effect Msg )
init =
    let
        seed = Random.initialSeed 0
    in
    (
        { inputText = ""
        , numWinners = "1"
        , results = []
        , error = Nothing
        , currentSeed = seed
        }
    , Effect.none )



-- UPDATE


type Msg
    = UpdateInputText String
    | UpdateNumWinners String
    | StartLottery
    | UpdateTime Posix

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UpdateInputText text ->
            ( { model | inputText = text, error = Nothing }, Effect.none )
        UpdateNumWinners num ->
            ( { model | numWinners = num, error = Nothing }, Effect.none )
        StartLottery ->
            let
                entries =
                    String.split "\n" model.inputText |> List.filter ((/=) "")
                maybeNumWinners =
                    String.toInt model.numWinners
            in
            case maybeNumWinners of
                Just n ->
                    if n > List.length entries then
                        ( { model | error = Just "Number of winners cannot be greater than the number of entries.", results = [] }, Effect.none )
                    else
                        let
                            shuffleGenerator = Random.List.shuffle entries
                            (shuffled, newSeed) = Random.step shuffleGenerator model.currentSeed
                            selected = List.take n shuffled
                        in
                        ( { model | results = selected, error = Nothing, currentSeed = newSeed }, Effect.none )
                Nothing ->
                    ( { model | error = Just "Invalid number of winners.", results = [] }, Effect.none )
        UpdateTime posix ->
            let
                newSeed = Random.initialSeed (Time.posixToMillis posix)
            in
            ( { model | currentSeed = newSeed }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ model =
    { title = "Lottery"
    , body =
        UI.layout
            [ UI.h1 "Lottery"
            , div []
                [ text "Enter the items for the lottery, one per line, and specify the number of winners."
                , textarea [ placeholder "Enter items, one per line", value model.inputText, onInput UpdateInputText ] []
                , input [ placeholder "Number of winners", value model.numWinners, onInput UpdateNumWinners, Html.Attributes.type_ "number" ] []
                , button [ onClick StartLottery ] [ text "Start Lottery" ]
                ]
            , case model.error of
                Just errorMsg ->
                    div [] [ text errorMsg ]
                Nothing ->
                    div []
                        [ h2 [] [ text "Results" ]
                        , div [] (List.map (\result -> div [] [ text result ]) model.results)
                        ]
            ]
    }