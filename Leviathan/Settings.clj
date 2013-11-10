(def key-bindings
  {;; nREPL menu

   [:cmd "i"] "connectToNRepl:"
   [[:ctrl "x"] [:ctrl "e"]] "evaluatePrecedingExpression:"
   ;; TODO: moar



   ;; Project menu

   [:fn "o"] "openProject:"
   [:cmd "t"] "newTab:"

   [:cmd "o"] "jumpToFile:"
   [:cmd :shift "o"] "jumpToDefinition:"
   [:cmd :ctrl "e"] "jumpToDefinitionAtPoint:"

   [:cmd :ctrl "right"] "addSplitToEast:"

   [:cmd :shift "["] "selectPreviousTab:"
   [:cmd :shift "]"] "selectNextTab:"

   [:cmd :ctrl "["] "selectPreviousSplit:"
   [:cmd :ctrl "]"] "selectNextSplit:"

   [:cmd :shift "left"] "moveTabLeft:"
   [:cmd :shift "right"] "moveTabRight:"

   [:cmd :shift "t"] "openTestInSplit:"

   [:cmd :ctrl "t"] "openProjectInTerminal:"
   [:cmd :ctrl "g"] "openProjectInGitx:"


   ;; Paredit menu

   [:cmd "/"] "commentLinesFirstExpression:"
   [:alt "q"] "indentCurrentSection:"

   [:ctrl "g"] "deselectText:"

   [[:cmd "k"] [:cmd "r"]] "raiseExpression:"
   [:ctrl :alt "k"] "deleteNextExpression:"
   [:ctrl "k"] "deleteToEndOfExpression:"
   [:alt "s"] "spliceExpression:"

   [:ctrl :alt "b"] "moveBackwardExpression:"
   [:ctrl :alt "f"] "moveForwardExpression:"
   [:ctrl :alt "d"] "moveIntoNextExpression:"
   [:ctrl :alt "p"] "moveIntoPreviousExpression:"
   [:ctrl :alt "u"] "moveOutExpressionBackward:"
   [:ctrl :alt "n"] "moveOutExpressionForward:"

   [:alt "m"] "moveToFirstNonBlankCharacterOnLine:"

   [:ctrl :alt "space"] "extendSelectionToNextExpression:"

   [:ctrl "9"] "wrapNextExpressionInParentheses:"
   [:ctrl "["] "wrapNextExpressionInBrackets:"
   [:ctrl :shift "["] "wrapNextExpressionInBraces:"

   [:alt :shift "]"] "moveToNextBlankLines:"
   [:alt :shift "["] "moveToPreviousBlankLines:"})

(def indent-like-functions
  ["ns"
   "let"
   "for"
   "assoc"
   "if"
   "if-let"
   "cond"
   "doto"
   "case"
   "list"])
