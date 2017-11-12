do

--   function string.split(str, delimiter)
--      local t = {}
--      for substr in str:gmatch('([^'..delimiter..']+)') do
--         t[#t+1] = substr
--      end
--      return t
--   end

   local function exportstring(s)
      return string.format("%q", s)
   end

   function table.save(tbl,filename)
      local charS,charE = "   ","\n"
      local file,err = io.open( filename, "wb" )
      if err then return err end

      local tables, lookup = { tbl },{ [tbl] = 1 }
      file:write("return {"..charE )

      for idx,t in ipairs( tables ) do
         file:write("-- Table: {"..idx.."}"..charE )
         file:write("{"..charE )
         local thandled = {}

         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )

            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write(charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               file:write(charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               file:write(charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do

            if (not thandled[i]) then

               local str = ""
               local stype = type( i )

               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end

               if str ~= "" then
                  stype = type( v )

                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     file:write(str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     file:write(str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     file:write(str..tostring( v )..","..charE )
                  end
               end
            end
         end
         file:write("},"..charE )
      end
      file:write("}" )
      file:close()
   end

   function table.load( sfile )
      local ftables,err = loadfile( sfile )
      if err then return _,err end
      local tables = ftables()
      for idx=1, #tables do
         local tolinki = {}
         for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
         end
         for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
         end
      end
      return tables[1]
   end

end