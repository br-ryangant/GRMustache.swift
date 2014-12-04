//
//  HTMLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class HTMLEscape: MustacheRenderable, MustacheFilter, MustacheTagObserver {
    
    
    // MARK: - MustacheRenderable
    
    func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering("\(self)")
        case .Section:
            return info.tag.render(info.context.extendedContext(tagObserver: self), error: error)
        }
    }

    
    // MARK: - MustacheFilter
    
    func mustacheFilterByApplyingArgument(argument: Value) -> MustacheFilter? {
        return nil
    }
    
    func transformedMustacheValue(value: Value, error: NSErrorPointer) -> Value? {
        if let string = value.toString() {
            return Value(escapeHTML(string))
        } else {
            return Value()
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
        switch tag.type {
        case .Variable:
            // {{ value }}
            //
            // We can not escape `object`, because it is not a string.
            // We want to escape its rendering.
            // So return a rendering object that will eventually render `object`,
            // and escape its rendering.
            return RenderableValue({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if let rendering = value.render(info, error: error) {
                    return Rendering(escapeHTML(rendering.string), rendering.contentType)
                } else {
                    return nil
                }
            })
        case .Section:
            return value
        }
    }
    
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
    }
}
