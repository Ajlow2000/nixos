function Hello_world()
    print("Wassup")
end

-- Quick print table (debugging)
-- function Print_table(t, s)
--     for k, v in pairs(t) do
--         local kfmt = '["' .. tostring(k) ..'"]'
--         if type(k) ~= 'string' then
--             kfmt = '[' .. k .. ']'
--         end
--         local vfmt = '"'.. tostring(v) ..'"'
--         if type(v) == 'table' then
--             Print_table(v, (s or '')..kfmt)
--         else
--             if type(v) ~= 'string' then
--                 vfmt = tostring(v)
--             end
--             print(type(t)..(s or '')..kfmt..' = '..vfmt)
--         end
--     end
-- end

