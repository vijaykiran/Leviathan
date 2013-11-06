{;; Project menu

 "openProject:" [:fn "o"]
 "newTab:" [:cmd "t"]

 "jumpToFile:" [:cmd "o"]
 "jumpToDefinition:" [:cmd :shift "o"]
 "jumpToDefinitionAtPoint:" [:cmd :ctrl "e"]

 "addSplitToEast:" [:cmd :ctrl "right"]

 "selectPreviousTab:" [:cmd :shift "["]
 "selectNextTab:" [:cmd :shift "]"]

 "selectPreviousSplit:" [:cmd :ctrl "["]
 "selectNextSplit:" [:cmd :ctrl "]"]

 "moveTabLeft:" [:cmd :shift "left"]
 "moveTabRight:" [:cmd :shift "right"]

 "openTestInSplit:" [:cmd :shift "t"]

 "openProjectInTerminal:" [:cmd :ctrl "t"]
 "openProjectInGitx:" [:cmd :ctrl "g"]


 ;; Paredit menu

 "commentLinesFirstExpression:" [:cmd "/"]
 "indentCurrentSection:" [:alt "q"]

 "raiseExpression:" [:alt "r"]
 "deleteNextExpression:" [:ctrl :alt "k"]
 "deleteToEndOfExpression:" [:ctrl "k"]
 "spliceExpression:" [:alt "s"]

 "moveBackwardExpression:" [:ctrl :alt "b"]
 "moveForwardExpression:" [:ctrl :alt "f"]
 "moveIntoNextExpression:" [:ctrl :alt "d"]
 "moveIntoPreviousExpression:" [:ctrl :alt "p"]
 "moveOutExpressionBackward:" [:ctrl :alt "u"]
 "moveOutExpressionForward:" [:ctrl :alt "n"]

 "moveToFirstNonBlankCharacterOnLine:" [:alt "m"]

 "extendSelectionToNextExpression:" [:ctrl :alt " "]

 "wrapNextExpressionInParentheses:" [:ctrl "9"]
 "wrapNextExpressionInBrackets:" [:ctrl "["]
 "wrapNextExpressionInBraces:" [:ctrl :shift "["]

 "moveToNextBlankLines:" [:alt :shift "]"]
 "moveToPreviousBlankLines:" [:alt :shift "["]}
