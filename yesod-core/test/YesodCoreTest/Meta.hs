{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ViewPatterns #-}

module YesodCoreTest.Meta
    ( metaTest
    ) where

import Test.Hspec

import Yesod.Core
import Network.Wai
import Network.Wai.Test

data App = App

mkYesod "App" [parseRoutes|
/title TitleR GET
/desc  DescriptionR GET
|]

instance Yesod App where

getTitleR :: Handler Html
getTitleR = defaultLayout $ do
    setTitle "First title"
    setTitle "Second title"

getDescriptionR :: Handler Html
getDescriptionR = defaultLayout $ do
    setDescription "First description"
    setDescription "Second description"

metaTest :: Spec
metaTest = describe "Setting page metadata" $ do
    describe "Yesod.Core.Widget.setTitle" $ do
        it "is idempotent" $ runner $ do
            res <- request defaultRequest
                        { pathInfo = ["title"]
                        }
            assertBody "<!DOCTYPE html>\n<html><head><title>Second title</title></head><body></body></html>" res
    describe "Yesod.Core.Widget.setDescription" $ do
        it "is idempotent" $ runner $ do
            res <- request defaultRequest
                        { pathInfo = ["desc"]
                        }
            assertBody "<!DOCTYPE html>\n<html><head><title></title><meta type=\"description\">Second description</meta></head><body></body></html>" res

runner :: Session () -> IO ()
runner f = toWaiAppPlain App >>= runSession f
