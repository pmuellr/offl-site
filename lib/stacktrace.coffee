#-------------------------------------------------------------------------------
# Copyright (c) 2012 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# for info on Error.stackTraceLimit/prepareStackTrace/captureStackTrace
# see: http://code.google.com/p/v8/wiki/JavaScriptStackTraceApi
#-------------------------------------------------------------------------------

MAX_STACK_FRAMES = 20

#-------------------------------------------------------------------------------
initV8stackGoop = () ->
#    return if true
    Error.stackTraceLimit   ||= MAX_STACK_FRAMES
    Error.prepareStackTrace ||= prepareStackTrace
    
    if process?
        process.on 'uncaughtException', (err) -> 
            console.error err.stack

#-------------------------------------------------------------------------------
class StackTrace

    #---------------------------------------------------------------------------
    @getCurrent: () ->
        new StackTrace().text
        
    #---------------------------------------------------------------------------
    constructor: () ->
        error = new Error()
        error.captureStackTrace(error, StackTrace)
        @text = error.stack || @getStackTheHardWay()
        
    #---------------------------------------------------------------------------
    getStackTheHardWay: () ->
        structuredStack = @getStructuredStack()
        
        prepareStackTrace null, structuredStack

    #---------------------------------------------------------------------------
    getStructuredStack: () ->
        frames = []
        func   = arguments.caller
        
        while func && (frames.length < MAX_STACK_FRAMES)
            frames.push new StackFrame(null, null, func)
            
            func = func.caller

        frames            

#-------------------------------------------------------------------------------
class StackFrame

    #---------------------------------------------------------------------------
    constructor: (@file, @line, func) ->
        @file ||= "<unknown file>"
        @line ||= 0
        
    #---------------------------------------------------------------------------
    getFileName:   () -> @file
    getLineNumber: () -> @line
    getFunction:   () -> @func

#-------------------------------------------------------------------------------
# returns  multi-line string of text 
# expects: array of StackFrame
#-------------------------------------------------------------------------------
prepareStackTrace = (error, structuredStackTrace) ->
    try 
        prepareStackTraceUnchecked error, structuredStackTrace
    catch e
        utils.error "error in prepareStackTrace():"
        utils.error "   #{e}"
    
#-------------------------------------------------------------------------------
prepareStackTraceUnchecked = (error, structuredStackTrace) ->
    result = []
    result.push "---------------------------------------------------------"
    result.push "error: #{error}"
    result.push "---------------------------------------------------------"
    result.push "stack: "

    longestFile = 0
    longestLine = 0
    
    for callSite in structuredStackTrace
        file = callSite.getFileName()
        line = callSite.getLineNumber()

        file = file.replace(/.*\//, '')
        line = "#{line}"
        
        if file.length > longestFile
            longestFile = file.length
    
        if line.length > longestLine
            longestLine = line.length
    
    for callSite in structuredStackTrace
        func = callSite.getFunction()
        file = callSite.getFileName()
        line = callSite.getLineNumber()

        file = file.replace(/.*\//, '')
        line = "#{line}"
        
        file = alignRight(file, longestFile)
        line = alignRight(line, longestLine)
        
        funcName = func.displayName ||
                   func.name || 
                   callSite.getFunctionName()
                   callSite.getMethodName()
                   '???'
        
        if funcName == "Module._compile"
            result.pop()
            result.pop()
            break
            
        result.push "   #{file} #{line} - #{funcName}()"
        
    result.join "\n"
    
#-------------------------------------------------------------------------------
alignLeft = (string, length) ->
    while string.length < length
        string = "#{string} "
        
    string

#-------------------------------------------------------------------------------
alignRight = (string, length) ->
    while string.length < length
        string = " #{string}"

    string

#-------------------------------------------------------------------------------
initV8stackGoop()
