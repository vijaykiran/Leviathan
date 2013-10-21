//
//  element.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef Leviathan_element_h
#define Leviathan_element_h

namespace leviathan {
    
    struct coll;
    
    struct element {
        
        coll& parent;
        size_t index;
        
    };
    
}

#endif
