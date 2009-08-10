
module Text.HTML.TagSoup.Options_ where

import Text.HTML.TagSoup.Type
import Text.HTML.TagSoup.Entity
import Text.StringLike


data ParseOptions str = ParseOptions
    {optTagPosition :: Bool -- ^ Should 'TagPosition' values be given before some items (default=False,fast=False)
    ,optTagWarning :: Bool  -- ^ Should 'TagWarning' values be given (default=False,fast=False)
    ,optEntityData :: str -> [Tag str] -- ^ How to lookup an entity
    ,optEntityAttrib :: (str,Bool) -> (str,[Tag str]) -- ^ How to lookup an entity in an attribute (Bool = has ending ';'?)
    ,optTagTextMerge :: Bool -- ^ Require no adjacent 'TagText' values (default=True,fast=False)
    }


parseOptions :: StringLike str => ParseOptions str
parseOptions = ParseOptions False False entityData entityAttrib True
    where
        entityData x = case lookupEntity y of
            Just y -> [TagText $ fromString1 y]
            Nothing -> [TagText $ fromString $ "&" ++ y ++ ";"
                       ,TagWarning $ fromString $ "Unknown entity: " ++ y]
            where y = toString x

        entityAttrib (x,b) = case lookupEntity y of
            Just y -> (fromString1 y, [])
            Nothing -> (fromString $ "&" ++ y ++ [';'|b], [TagWarning $ fromString $ "Unknown entity: " ++ y])
            where y = toString x


parseOptionsFast :: StringLike str => ParseOptions str
parseOptionsFast = parseOptions{optTagTextMerge=False}


parseOptionsRetype :: (StringLike from, StringLike to) => ParseOptions from -> ParseOptions to
parseOptionsRetype (ParseOptions a b c d e) = ParseOptions a b c2 d2 e
    where
        re1 = fromString . toString
        re2 = fromString . toString
        c2 x = map (fmap re1) $ c $ re2 x
        d2 (x,y) = (re1 r, map (fmap re1) s)
            where (r,s) = d (re2 x, y)
