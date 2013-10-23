////
////  atom.h
////  Leviathan
////
////  Created by Steven on 10/20/13.
////  Copyright (c) 2013 Steven Degutis. All rights reserved.
////
//
//#ifndef __Leviathan__atom__
//#define __Leviathan__atom__
//
//#include <iostream>
//
//#include "element.h"
//#include "token.h"
//
//namespace Leviathan {
//    
//    struct Atom: public Element {
//        
//        enum Type : uint64_t {
//            Symbol  = 1 << 0,
//            String  = 1 << 1,
//            Number  = 1 << 2,
//            Keyword = 1 << 3,
//            
//            Spaces  = 1 << 4,
//            
//            TrueAtom  = 1 << 5, // must also be Symbol
//            FalseAtom = 1 << 6, // must also be Symbol
//            NilAtom   = 1 << 7, // must also be Symbol
//            
//            Deflike = 1 << 8, // must also be Symbol
//            Ns      = 1 << 9, // must also be Symbol
//        };
//        
//        uint64_t atomType;
//        Token* token;
//        
//        Atom(int type, Token* tok) : atomType(type), token(tok) {} ;
//        ~Atom();
//        
//        size_t length();
//        
//    };
//    
//    std::ostream& operator<<(std::ostream& os, Atom::Type t);
//    
//}
//
//#endif /* defined(__Leviathan__atom__) */
