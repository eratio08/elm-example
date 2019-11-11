module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, string, succeed)
import Json.Decode.Pipeline exposing (required)


main : Program () Model Msg
main =
    Browser.element
        { init = initialModel
        , subscriptions = subscriptions
        , view = view
        , update = update
        }


type Msg
    = GotUser (Result Http.Error User)
    | LoadUser


type alias User =
    { id : String
    , username : String
    , email : String
    }


type alias Model =
    { currentUser : Maybe User
    , error : Maybe Http.Error
    }


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    ( { currentUser = Nothing, error = Nothing }, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text (Debug.toString model), Html.button [ onClick LoadUser ] [ text "Load User" ] ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUser (Err error) ->
            ( { model | currentUser = Nothing, error = Just error }, Cmd.none )

        GotUser (Ok user) ->
            ( { model | currentUser = Just user }, Cmd.none )

        LoadUser ->
            ( model, getUser )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


backendUrl : String
backendUrl =
    "http://localhost:1337"


getUser : Cmd Msg
getUser =
    Http.get
        { url = backendUrl ++ "/users"
        , expect = Http.expectJson GotUser userDecoder
        }


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "id" string
        |> required "username" string
        |> required "email" string
