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
util   = require 'util'
crypto = require 'crypto'

utils   = require '../utils'
FileSet = require '../FileSet'

#-------------------------------------------------------------------------------
module.exports = class Processor extends events.EventEmitter

    #---------------------------------------------------------------------------
    constructor: (@iDir, @oDir, @options) ->
        @records = []
    
    #---------------------------------------------------------------------------
    process: ->
        @iDirFull = path.resolve @iDir
        @oDirFull = path.resolve @oDir
        
        if !path.existsSync @iDirFull
            @emitErrorMessage "input directory '#{@iDir}' does not exist"
            return
        
        if !path.existsSync @oDirFull
            @emitErrorMessage "output directory '#{@oDir}' does not exist"
            return
        
        iStats = fs.statSync @iDirFull
        oStats = fs.statSync @oDirFull
        
        if !iStats.isDirectory()
            @emitErrorMessage "input directory '#{@iDir}' is not a directory"
            return
            
        if !oStats.isDirectory()
            @emitErrorMessage "output directory '#{@oDir}' is not a directory"
            return

        if @iDirFull == @oDirFull            
            @emitErrorMessage "the input and output directory cannot be the same"
            return
            
        @checkForMain @iDirFull
        
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

        @emptyDir(@oDirFull)
        @copyFiles(@oDirFull, @iDirFull, @)

        @writeManifest()
        @writeHtAccess()
        @writeGitIgnore()

        utils.log "site created in: #{@oDir}"
        
        @emit 'done'

    #---------------------------------------------------------------------------
    writeHtAccess: ->
        htAccess = path.join(@oDirFull, '.htaccess')
        return if path.existsSync(htAccess)

        contents = """
            # add header for CORS
            Header set Access-Control-Allow-Origin *        
        """

        fs.writeFileSync htAccess, contents
        utils.logVerbose "created: #{htAccess}"
        
    #---------------------------------------------------------------------------
    writeGitIgnore: ->
        gitIgnore = path.join(@oDirFull, '.gitignore')
        return if path.existsSync(gitIgnore)

        contents = """
            # skip base64 encoded binaries
            *.jpg.data
            *.png.data
            *.gif.data
        """

        fs.writeFileSync gitIgnore, contents
        utils.logVerbose "created: #{gitIgnore}"
        
    #---------------------------------------------------------------------------
    writeManifest: ->
        manifest = path.join(@oDirFull, 'offl-site.manifest.json')
        contents = JSON.stringify(@records, null, 4)
        fs.writeFileSync manifest, contents
        
        manifest = path.join(@oDir, path.basename(manifest))
        utils.logVerbose "created: #{manifest}"


    #---------------------------------------------------------------------------
    checkForMain: (dir) ->
        exts = [
            ".html"
            ".ms.html"
            ".md"
            ".ms.md"
        ]
        
        for ext in exts
            fileName = "#{dir}/main#{ext}"
            return if path.existsSync(fileName)
            
        @emitErrorMessage "a 'main' page was not found in the input directory"

    #---------------------------------------------------------------------------
    addFileRecord: (file, origFile, stats, encoding) ->
    
        record = 
            path: file
            size: stats.size
            
        if file != origFile
            record.origPath = origFile
            
        if encoding
            record.encoding = encoding
            
        @records.push record
        
    #---------------------------------------------------------------------------
    emitErrorMessage: (message) ->
        @emit 'error', new Error(message)

    #---------------------------------------------------------------------------
    copyFiles: (toDir, fromDir, processor) ->
        fileSet = FileSet.fromDir(fromDir)
    
        for dir in fileSet.relDirs()
            dir = path.join(toDir, dir)
            fs.mkdirSync(dir)
            utils.logVerbose "created: #{dir}/"
    
        for file in fileSet.relFiles()
            fromFile = path.join(fromDir, file)
            toFile   = path.join(toDir,   file)
            @copyFile(toFile, fromFile, file)
    
    #---------------------------------------------------------------------------
    copyFile: (toFile, fromFile, relFile) ->
        origRelFile = relFile
    
        contents = fs.readFileSync(fromFile)
        encoding = null
        
        if @shouldUseBase64 toFile
            toFile   = "#{toFile}.data"
            relFile  = "#{relFile}.data"
            contents = contents.toString 'base64'
            encoding = 'base64'
    
        fs.writeFileSync(toFile, contents)
        
        fStats = fs.statSync fromFile
        tStats = fs.statSync toFile
        
        fs.utimesSync toFile, fStats.atime, fStats.mtime
        
        utils.logVerbose "copied:  #{relFile}"
        
        @addFileRecord relFile, origRelFile, fStats, encoding

    
    #---------------------------------------------------------------------------
    shouldUseBase64: (file) ->
        matchers = [
            /.*\.JPG$/
            /.*\.GIF$/
            /.*\.PNG$/
        ]
        
        file = file.toUpperCase()
        
        for matcher in matchers
            return true if file.match matcher 
            
        return false
    
    #---------------------------------------------------------------------------
    emptyDir: (dir) ->
        fileSet = FileSet.fromDir(dir)
        
        for file in fileSet.fullFiles()
            utils.logVerbose "erased:  #{file}"
            fs.unlinkSync file
    
        
        for dir in fileSet.fullDirs().reverse()
            utils.logVerbose "rmdir:   #{dir}"
            fs.rmdirSync dir
    
