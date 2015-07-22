json.array!(@listings) do |listing|
  json.extract! listing, :sold_date
end
