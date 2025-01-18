module Pages.Lottery exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.Lottery exposing (Params)
import Html exposing (button, div, h1, input, text, textarea)
import Html.Events as Events
import Page
import Request
import Shared
import UI
import View exposing (View)
import Html exposing (p)
import Html exposing (h2)
import Html exposing (h3)
import Html.Attributes exposing (placeholder)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput)
import Html.Events exposing (onClick)
import Time exposing (Posix)
import Random


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
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
        , currentSeed = seed
        }
    , Effect.none )



-- UPDATE


type Msg
    = IncrementShared
    | DecrementShared
    | UpdateInputText String
    | UpdateNumWinners String
    | StartLottery
    | UpdateTime Posix

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        IncrementShared ->
            ( model
            , Effect.fromShared Shared.Increment
            )

        DecrementShared ->
            ( model
            , Effect.fromShared Shared.Decrement
            )
        UpdateInputText text ->
            ( { model | inputText = text }, Effect.none )
        UpdateNumWinners num ->
            ( { model | numWinners = num }, Effect.none )
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
            ( { model | results = selected, currentSeed = newSeed }, Effect.none )
        UpdateTime posix ->
            let
                newSeed = Random.initialSeed (Time.posixToMillis posix)
            in
            ( { model | currentSeed = newSeed }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Lottery"
    , body =
        UI.layout
            [ UI.h1 "Lottery"
            , p [] [ text "An advanced page uses Effects instead of Cmds, which allow you to send Shared messages directly from a page." ]
            , h2 [] [ text "Shared Counter" ]
            , h3 [] [ text (String.fromInt shared.counter) ]
            , button [ Events.onClick DecrementShared ] [ text "-" ]
            , button [ Events.onClick IncrementShared ] [ text "+" ]
            , p [] [ Html.text "This value doesn't reset as you navigate from one page to another (but will on page refresh)!" ]
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
    }