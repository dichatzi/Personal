on_list, upd_list = dcUtils.create_upsert_lists(all_fields=columns, on_fields=["res_portfolio_name", "reference_time_from", "reference_time_to"])

# Data manipulation
for period in ["from", "to"]:
  data[f"reference_time_{period}"] = pd.to_datetime(data[f"reference_time_{period}"])

# Upload data to database
dcUtils.upsert_data(sql_object=db, dataframe=data, database="optimus_energy", schema="market_results", table="clearing_report", on_fields=on_list, upd_fields=upd_list)
