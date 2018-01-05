{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Docker.Nix.FetchDocker
-- Copyright   :  (C) 2017 Awake Networks
-- License     :  Apache-2.0
-- Maintainer  :  Awake Networks <opensource@awakenetworks.com>
-- Stability   :  stable
----------------------------------------------------------------------------

module Tests.Data.Docker.Nix.FetchDocker where

import           Control.Exception            as CE
import           Control.Monad.Except         as Except
import           Data.ByteString.Lazy.Char8   as C8L
import           Data.Either                  (either)
import qualified Data.Text                    as Text
import           Network.URI

import           Test.Tasty
import           Test.Tasty.Golden
import           Test.Tasty.HUnit
import           Text.PrettyPrint.ANSI.Leijen as Text.PrettyPrint (displayS)

import           Data.Docker.Image.Types
import           Data.Docker.Nix.FetchDocker  as Nix.FetchDocker
import           Data.Docker.Nix.Lib          as Nix.Lib
import           Hocker.Lib
import           Network.Wreq.Docker.Registry as Docker.Registry
import           Hocker.Types
import           Hocker.Types.ImageTag

tests = testGroup "FetchDocker Nix Generation Tests"
  [ goldenVsString
      "Golden vs. Generated `fetchDocker' Nix Expression"
      "test/data/golden-debian:jessie.nix"
      generateFetchDockerNix
  , testCase "Base16 Digest to Base32 Digest" testBase16toBase32
  ]

testBase16toBase32 :: Assertion
testBase16toBase32 = do
  let b16     = Base16Digest "5c90d4a2d1a8dfffd05ff2dd659923f0ca2d843b5e45d030e17abbcd06a11b5b"
      b32     = Base32Digest "0nqvl43cvfvsw4qd0iay7f22vjph4fcnbpgjbz8gzpx8s6id942w"

  res <- Except.runExceptT (Nix.Lib.toBase32Nix b16)

  either
    (assertFailure . show)
    (assertEqual "" b32)
    res

generateFetchDockerNix :: IO C8L.ByteString
generateFetchDockerNix = do
  manifest      <- C8L.readFile "test/data/manifest-debian:jessie.json"
  nixExpression <- Nix.FetchDocker.generate
    HockerImageMeta
      { imageRepo      = "library"
      , imageName      = "debian"
      , imageTag       = ImageTag "jessie"
      , manifestJSON   = manifest
      , dockerRegistry = defaultRegistry
      , altImageName   = Nothing
      }

  either
    (Hocker.Lib.die . Text.pack . show)
    (return . C8L.pack . (flip displayS "") . Hocker.Lib.renderNixExpr)
    nixExpression
