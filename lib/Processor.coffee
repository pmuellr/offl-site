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

fs     = require 'fs'
path   = require 'path'
events = require 'events'

utils = require './utils'

#-------------------------------------------------------------------------------
module.exports = class Processor extends events.EventEmitter

    #---------------------------------------------------------------------------
    constructor: (@iDir, @oDir, @options) ->
    
    #---------------------------------------------------------------------------
    process: ->
        @iDirFull = path.resolve @iDir
        @oDirFull = path.resolve @oDir
        
        if !path.existsSync @iDirFull
            @_emitErrorMessage "input directory '#{@iDir}' does not exist"
            return
        
        if !path.existsSync @oDirFull
            @_emitErrorMessage "output directory '#{@oDir}' does not exist"
            return
        
        iStats = fs.statSync @iDirFull
        oStats = fs.statSync @oDirFull
        
        if !iStats.isDirectory()
            @_emitErrorMessage "input directory '#{@iDir}' is not a directory"
            return
            
        if !oStats.isDirectory()
            @_emitErrorMessage "output directory '#{@oDir}' is not a directory"
            return

        if @iDirFull == @oDirFull            
            @_emitErrorMessage "the input and output directory cannot be the same"
            return
        
        console.log "iDir:    #{@iDir} #{@iDirFull}"
        console.log "oDir:    #{@oDir} #{@oDirFull}"
        console.log "options: #{JSON.stringify(@options)}"

        @emit 'done'

    #---------------------------------------------------------------------------
    _emitErrorMessage: (message) ->
        @emit 'error', new Error(message)
