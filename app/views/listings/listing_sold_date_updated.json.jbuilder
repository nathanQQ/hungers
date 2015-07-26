json.array!(@listings) do |listing|
  json.extract! listing, :id, :sold_date
end
