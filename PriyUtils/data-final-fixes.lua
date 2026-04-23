-- 修改 rocket-fuel 的堆叠数量为 1000
if data.raw.item["rocket-fuel"] then
  data.raw.item["rocket-fuel"].stack_size = 1000
  -- 同时修改默认请求数量
  data.raw.item["rocket-fuel"].default_request_amount = 1000
end

--插件分享塔的堆叠数量为 1000
if data.raw.item["beacon"] then
  data.raw.item["beacon"].stack_size = 1000
  -- 同时修改默认请求数量
  data.raw.item["beacon"].default_request_amount = 1000
end
