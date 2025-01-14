module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, input, text, textarea)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Random
import Time exposing (Posix)


-- MODEL
type alias Model =
    { inputText : String
    , numWinners : String
    , results : List String
    , currentSeed : Random.Seed
    }


initialModel : Random.Seed -> Model
initialModel seed =
    { inputText = ""
    , numWinners = ""
    , results = []
    , currentSeed = seed
    }


-- UPDATE
type Msg
    = UpdateInputText String
    | UpdateNumWinners String
    | StartLottery
    | UpdateTime Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInputText text ->
            ( { model | inputText = text }, Cmd.none )

        UpdateNumWinners num ->
            ( { model | numWinners = num }, Cmd.none )

        StartLottery ->
            let
                entries =
                    String.split "\n" model.inputText |> List.filter ((/=) "")

                maybeNumWinners =
                    String.toInt model.numWinners

                (selected, newSeed) =
                    case maybeNumWinners of
                        Just n ->
                            let
                                generator = Random.list n (Random.uniform "a" entries)
                            in
                            Random.step generator model.currentSeed

                        Nothing ->
                            ( [], model.currentSeed )
            in
            ( { model | results = selected, currentSeed = newSeed }, Cmd.none )

        UpdateTime posix ->
            let
                newSeed = Random.initialSeed (Time.posixToMillis posix)
            in
            ( { model | currentSeed = newSeed }, Cmd.none )


-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Lottery App" ]
        , div []
            [ textarea [ placeholder "Enter items, one per line", value model.inputText, onInput UpdateInputText ] []
            , input [ placeholder "Number of winners", value model.numWinners, onInput UpdateNumWinners ] []
            , button [ onClick StartLottery ] [ text "Start Lottery" ]
            ]
        , div []
            [ h1 [] [ text "Results" ]
            , div [] (List.map (\result -> div [] [ text result ]) model.results)
            ]
        ]


-- MAIN
main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel (Random.initialSeed 0), Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Time.every 1000 UpdateTime
        }
