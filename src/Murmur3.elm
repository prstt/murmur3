module Murmur3 exposing (hashString)

{-| Murmur 3 hash function for hashing strings

@docs hashString

-}

import Bitwise exposing (..)
import Char


{-| Takes a seed and a string. Produces a hash (integer).
Given the same seed and string, it will always produce the same hash.

    hashString 1234 "Turn me into a hash" == 4138100590

-}
hashString : Int -> String -> Int
hashString seed str =
    str
        |> String.foldr prepareString []
        |> listHash (String.length str) seed


prepareString : Char -> List Int -> List Int
prepareString char acc =
    (Char.toCode char |> and 0xFF) :: acc


listHash : Int -> Int -> List Int -> Int
listHash strLength hash chars =
    case chars of
        [] ->
            finalize strLength hash

        a :: r1 ->
            let
                c1 =
                    a
            in
                case r1 of
                    [] ->
                        finalize strLength (mix hash c1)

                    b :: r2 ->
                        let
                            c2 =
                                b
                                    |> shiftLeftBy 8
                                    |> or c1
                        in
                            case r2 of
                                [] ->
                                    finalize strLength (mix hash c2)

                                c :: r3 ->
                                    let
                                        c3 =
                                            c
                                                |> shiftLeftBy 16
                                                |> or c2
                                    in
                                        case r3 of
                                            [] ->
                                                finalize strLength (mix hash c3)

                                            d :: r4 ->
                                                let
                                                    c4 =
                                                        d
                                                            |> shiftLeftBy 24
                                                            |> or c3
                                                            |> mix hash
                                                            |> step
                                                in
                                                    listHash strLength c4 r4


finalize : Int -> Int -> Int
finalize strLength hash =
    let
        h1 =
            Bitwise.xor hash strLength

        h2 =
            h1
                |> shiftRightZfBy 16
                |> Bitwise.xor h1
                |> mur 0x85EBCA6B

        h3 =
            h2
                |> shiftRightZfBy 13
                |> Bitwise.xor h2
                |> mur 0xC2B2AE35
    in
        h3
            |> shiftRightZfBy 16
            |> Bitwise.xor h3
            |> shiftRightZfBy 0


mix : Int -> Int -> Int
mix h1 h2 =
    let
        k1 =
            mur 0xCC9E2D51 h2
    in
        k1
            |> shiftLeftBy 15
            |> or (shiftRightZfBy 17 k1)
            |> mur 0x1B873593
            |> Bitwise.xor h1


mur : Int -> Int -> Int
mur c h =
    and 0xFFFFFFFF (((and h 0xFFFF) * c) + (shiftLeftBy 16 (and 0xFFFF ((shiftRightZfBy 16 h) * c))))


step : Int -> Int
step acc =
    let
        h1 =
            shiftLeftBy 13 acc
                |> or (shiftRightZfBy 19 acc)
                |> mur 5
    in
        ((and h1 0xFFFF) + 0x6B64) + (shiftLeftBy 16 (and 0xFFFF ((shiftRightZfBy 16 h1) + 0xE654)))
