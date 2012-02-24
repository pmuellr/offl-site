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

utils   = require './utils'
FileSet = require './FileSet'

#-------------------------------------------------------------------------------
module.exports = class Processor extends events.EventEmitter

    #---------------------------------------------------------------------------
    constructor: (@iDir, @oDir, @options) ->
    
    #---------------------------------------------------------------------------
    process: ->
        @iDirFull = path.resolve @iDir
        @oDirFull = path.resolve @oDir
        
        if !path.existsSync @iDirFull
            emitErrorMessage "input directory '#{@iDir}' does not exist"
            return
        
        if !path.existsSync @oDirFull
            emitErrorMessage "output directory '#{@oDir}' does not exist"
            return
        
        iStats = fs.statSync @iDirFull
        oStats = fs.statSync @oDirFull
        
        if !iStats.isDirectory()
            emitErrorMessage "input directory '#{@iDir}' is not a directory"
            return
            
        if !oStats.isDirectory()
            emitErrorMessage "output directory '#{@oDir}' is not a directory"
            return

        if @iDirFull == @oDirFull            
            emitErrorMessage "the input and output directory cannot be the same"
            return
        
#        console.log "iDir:    #{@iDir} #{@iDirFull}"
#        console.log "oDir:    #{@oDir} #{@oDirFull}"
#        console.log "options: #{JSON.stringify(@options)}"
#        console.log ""
        
#        iFileSet = FileSet.fromDir(@iDirFull)
#        oFileSet = FileSet.fromDir(@oDirFull)
        
#        console.log "iDir files:"
#        iFileSet.dump()
#        console.log ""
        
#        console.log "oDir files:"
#        oFileSet.dump()

        emptyDir(@oDirFull)
        copyFiles(@oDirFull, @iDirFull)
        
        @emit 'done'

#-------------------------------------------------------------------------------
copyFiles = (toDir, fromDir) ->
    fileSet = FileSet.fromDir(fromDir)

    for dir in fileSet.relDirs()
        dir = path.join(toDir, dir)
#        fs.mkdirSync(dir)
        console.log "woulda mkdir'd  #{dir}"

    for file in fileSet.relFiles()
        copyFile(file, toDir)

#-------------------------------------------------------------------------------
copyFile = (file, toDir) ->
    console.log "woulda copied #{file} to #{toDir}"

#-------------------------------------------------------------------------------
emptyDir = (dir) ->
    fileSet = FileSet.fromDir(dir)
    
    for file in fileSet.fullFiles()
#        fs.unlinkSync(file)
        console.log "woulda unlink'd #{file}"

    
    for dir in fileSet.fullDirs().reverse()
#        fs.rmdirSync(file)
        console.log "woulda rmdir'd  #{dir}"

#-------------------------------------------------------------------------------
emitErrorMessage = (message) ->
    @emit 'error', new Error(message)
