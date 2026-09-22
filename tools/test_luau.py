#!/usr/bin/env python3
"""Compile real Luau sources, then run pure rules + persistence with fake stores.
Does not emulate Roblox physics, rendering, replication, or engine scheduling.
"""
import argparse
from pathlib import Path
import subprocess
import tempfile
ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--luau', default='luau')
parser.add_argument('--compile', default='luau-compile')
args = parser.parse_args()
for path in (ROOT/'src').rglob('*.lua'):
    subprocess.run([args.compile, str(path)], check=True, stdout=subprocess.DEVNULL)
print('All Luau sources compile', flush=True)
prelude = '''
local function deepcopy(x)
    if type(x)~='table' then return x end
    local out={}; for k,v in pairs(x) do out[k]=deepcopy(v) end; return out
end
local Color3={fromRGB=function(...) return {...} end}
local Vector3={new=function(...) return {...} end}
local task={wait=function() end,spawn=function(fn) fn() end}
local warn=function() end
local DSS={GetDataStore=function() return {} end,GetOrderedDataStore=function() return {SetAsync=function() end} end}
local Http={GenerateGUID=function() return 'test-token' end,JSONEncode=function(_,x) return deepcopy(x) end,JSONDecode=function(_,x) return deepcopy(x) end}
local game={JobId='test',GetService=function(_,name)
    if name=='DataStoreService' then return DSS end
    if name=='HttpService' then return Http end
    return {Shared={}}
end}
local Instance={new=function()
    return setmetatable({}, {__newindex=function(t,k,v)
        rawset(t,k,v); if k=='Parent' and v and t.Name then v[t.Name]=t end
    end})
end}
'''
def module(name, path, replacements=()):
    code=(ROOT/path).read_text()
    for old,new in replacements:
        code=code.replace(old,new)
    return f'\nlocal {name}=(function()\n{code}\nend)()\n'
script=prelude
script+=module('Config','src/ReplicatedStorage/Shared/Config.lua')
script+=module('Courses','src/ReplicatedStorage/Shared/Courses.lua')
script+=module('Economy','src/ReplicatedStorage/Shared/Economy.lua')
script+=module('Data','src/ServerScriptService/Services/DataService.lua',[
    ('local Config=require(Shared.Config)',''),('local Economy=require(Shared.Economy)','')])
script+=(ROOT/'tests/rules.luau').read_text()
with tempfile.TemporaryDirectory() as tmp:
    path=Path(tmp)/'suite.luau';path.write_text(script)
    subprocess.run([args.luau,str(path)],check=True)
