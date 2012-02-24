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

#-------------------------------------------------------------------------------
module.exports = class FileTree

    #---------------------------------------------------------------------------
    @fromDir: (dir) ->
        fileTree = new FileTree(dir)
        
        try
            collectTree(dir, "", fileTree.files, fileTree.dirs)
        
        catch e
            throw e
            return null

        fileTree            

    #---------------------------------------------------------------------------
    constructor: (@baseDir) ->
        @files = []
        @dirs  = []
    
    #---------------------------------------------------------------------------
    relFiles: () ->
        @files.slice()
    
    #---------------------------------------------------------------------------
    fullFiles: () ->
        for file in @files
            path.join(@baseDir, file)

    #---------------------------------------------------------------------------
    relDirs: () ->
        @dirs.slice()
    
    #---------------------------------------------------------------------------
    fullDirs: () ->
        for dir in @dirs
            path.join(@baseDir, dir)

    #---------------------------------------------------------------------------
    dump: () ->
        console.log "base directory: #{@baseDir}"
        
        for file in @relFiles()
            console.log "   #{file}"

#-------------------------------------------------------------------------------
collectTree = (dir, prefix, files, dirs) ->

    entries = fs.readdirSync(dir)
    
    for entry in entries
        fullName = path.join(dir, entry)
        relName  = path.join(prefix, entry)
        
        stat = fs.statSync(fullName)
        
        files.push(relName) if stat.isFile()
        dirs.push(relName)  if stat.isDirectory()
        
        if stat.isDirectory()
            collectTree(fullName, relName, files, dirs)
    
    
    
    
    
    
    
    
    
    
    
    
    
    

