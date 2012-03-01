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

fs   = require 'fs'
path = require 'path'

stackTrace = require './stackTrace'

#-------------------------------------------------------------------------------
class Utils

    #---------------------------------------------------------------------------
    constructor: ->
        @verbose = false

    #---------------------------------------------------------------------------
    error: (message) ->
        console.error "#{@PROGRAM}: #{message}"
        process.exit -1

    #---------------------------------------------------------------------------
    throwError: (message) ->
        error = new Error(message)
        error.stack = stackTrace.getCurrent()
        
        throw error

    #---------------------------------------------------------------------------
    readFile: (fileName) ->
        return null if !path.existsSync(fileName)
        
        contents = fs.readFileSync(fileName, 'utf-8')
        
        return @trim(contents)
    
    #---------------------------------------------------------------------------
    exit: ->
        process.exit
    
    #---------------------------------------------------------------------------
    setVerbose: (@verbose) ->
    
    #---------------------------------------------------------------------------
    logVerbose: (message) ->
        @log(message) if @verbose
        
    #---------------------------------------------------------------------------
    log: (message) ->
        console.log "#{@PROGRAM}: #{message}"
    
    #---------------------------------------------------------------------------
    trim: (string) ->
        string.replace /^\s+|\s+$/g, ''
    
#-------------------------------------------------------------------------------
utils = module.exports = new Utils

#-------------------------------------------------------------------------------
utils.PROGRAM = path.basename(process.argv[1])

#-------------------------------------------------------------------------------
moduleDir = path.dirname(fs.realpathSync(__filename)) 
jsonFile  = path.join(moduleDir, '..', 'package.json')

json = fs.readFileSync(jsonFile, 'utf8')
values = JSON.parse(json)

utils.VERSION = values.version
