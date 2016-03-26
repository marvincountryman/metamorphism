error "DO NOT RUN THIS FUCKHEAD"

local _FILE_ = arg[0]

-- Lua Library
local _g_            = _G
local _encode_       = string.char
local _os_           = _g_["os"]
local _io_           = _g_["io"]
local _math_         = _g_["math"]
local _table_        = _g_["table"]
local _string_       = _g_["string"]

local _pairs_        = _g_["pairs"]
local _tostring_     = _g_["tostring"]
local _tonumber_     = _g_["tonumber"]
local _getmetatable_ = _g_["getmetatable"]

-- io, os
local _ostime_ = _os_["time"]
local _ioopen_ = _io_["open"]

-- math
local _mathFmod_       = _math_["fmod"]
local _mathFloor_      = _math_["floor"]
local _mathRandom_     = _math_["random"]
local _mathRandomSeed_ = _math_["randomseed"]

-- string
local _stringLen_    = _string_["len"]
local _stringSub_    = _string_["sub"]
local _stringByte_   = _string_["byte"]
local _stringChar_   = _string_["char"]
local _stringGsub_   = _string_["gsub"]
local _stringFind_   = _string_["find"]
local _stringGmatch_ = _string_["gmatch"]
local _stringFormat_ = _string_["format"]

-- table
local _tableConcat_  = _table_["concat"]

-- File
local _fileMt_
do 
    local _tmp_ = _ioopen_(_FILE_, "r")
    _fileMt_ = _getmetatable_(_tmp_);
    _tmp_["close"](_tmp_)
end
local _fileMtRead_  = _fileMt_["read"]
local _fileMtWrite_ = _fileMt_["write"]
local _fileMtClose_ = _fileMt_["close"]

-- Shell
local _file_ = {}
local _obfuscator_ = {}

-- File
do
    function _file_._readSelf_()
        local _file_ = _ioopen_(_FILE_, "r")
        local _data_ = _fileMtRead_(_file_, "*a")

        _fileMtClose_(_file_)

        return _data_
    end
    function _file_._writeSelf_(_data_)
        local _file_ = _ioopen_("shell.lua", "w+")

        _fileMtWrite_(_file_, _data_)
        _fileMtClose_(_file_)
    end
end

-- Obfuscator
do
    _mathRandomSeed_(_ostime_())
    for i = 1, _mathRandom_(5, 255) do
        _mathRandomSeed_((_ostime_() + i) * _mathRandom_(5, 255))
    end

    local _offset_ = _mathRandom_(1, 1200)
    local _names_ = {}
    local _list_ = {}

    for _i_ = 97, 122 do
        _list_[#_list_ + 1] = _stringChar_(_i_)
    end

    local function _genNameFromId_(_i_)
        local _out_ = ""
        local _len_ = #_list_

        while _i_ > _len_ - 1 do
            _out_ = _list_[_mathFmod_(_i_, _len_) + 1] .. _out_
            _i_ = _mathFloor_(_i_ / _len_)
        end

        return "_".._list_[_i_] .. _out_.."_"
    end
    local function _genName_(_orig_)
        if _names_[_orig_] then
            return _names_[_orig_]
        else
            local _name_ = _genNameFromId_(_offset_)

            for _ok_, _nv_ in _pairs_(_names_) do
                if _nv_ == _name_ then
                    _offset_ = _mathRandom_(1, 1200)
                    return _genName_(_orig_)
                end
            end

            _names_[_orig_] = _name_
            _offset_ = _offset_ + 1
            return _name_
        end
    end
    local function _genString_(_value_)
        local _chars_ = {}

        if _stringLen_(_value_) > 2 then
            for _char_ in _stringGmatch_(_value_, "[^\"]") do
                _chars_[#_chars_ + 1] = _stringByte_(_char_)
            end
            return _stringFormat_("(_encode_(%s))", _tableConcat_(_chars_, ","))
        else
            return "''"
        end
    end

    function _obfuscator_._modifyLocals_(_code_)
        local _i_   = 1
        local _len_ = _stringLen_(_code_)
        local _end_ 
        local _name_
        local _start_

        while _i_ < _len_ do
            _start_, _end_ = _stringFind_(_code_, "(_[%a_][%w_]*_)[^_]", _i_)

            if _start_ ~= nil then 
                local _old_name_ = _stringSub_(_code_, _start_, _end_ - 1)
                local _new_name_ = _genName_(_old_name_)

                _code_ = _stringGsub_(_code_, _stringFormat_("(%s)", _old_name_), _new_name_)
                _i_ = _start_ + _stringLen_(_new_name_) + 1
            else
                break
            end
        end

        return _code_
    end
    function _obfuscator_._modifyString_(_code_)
        local _i_       = 1
        local _c_       = ""
        local _len_     = _stringLen_(_code_)
        local _buffer_  = ""
        local _strings_ = {}

        while _i_ < _len_ do
            _start_ = _stringFind_(_code_, "\"", _i_)

            if _start_ ~= nil then
                _i_ = _start_ + 1

                while _i_ < _len_ do
                    _c_ = _stringSub_(_code_, _i_, _i_)

                    if _c_ == "\\" then
                        _i_ = _i_ + 1
                        _c_ = _stringSub_(_code_, _i_, _i_)

                        if _c_ == "\"" then
                            _buffer_ = _buffer_ .. "\""
                        else
                            _buffer_ = _buffer_ .. "\\" .. _c_
                        end
                    elseif _c_ == "\"" then
                        _strings_[#_strings_ + 1] = _buffer_
                        _buffer_ = ""
                        _i_ = _i_ + 1

                        break
                    else
                        _buffer_ = _buffer_ .. _c_
                    end

                    _i_ = _i_ + 1
                end
            else
                break
            end
        end
        for _i_ = 1, #_strings_ do
            local _str_ = "\"" .. _stringGsub_(_strings_[_i_], "\"", "\\\"") .. "\""
            local _start_, _end_ = _stringFind_(_code_, _str_, 1, true)
            if _start_ ~= nil then
                _code_ = _stringSub_(_code_, 1, _start_ - 1) ..
                         _genString_(_str_) ..
                         _stringSub_(_code_, _end_ + 1)
            end
        end

        return _code_
    end
end

function _main_()
    _file_._writeSelf_(
        _obfuscator_._modifyLocals_(
        _obfuscator_._modifyString_(
            _file_._readSelf_()
        ))
    )
end

_main_()