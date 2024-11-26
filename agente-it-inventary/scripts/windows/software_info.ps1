$python_dependencies = (pip freeze) -join "`n"
$python_dependencies = $python_dependencies -replace '"', '\"'

$json_output = @"
{
  "result": [
    {
      "field": "Librerias Python instaladas",
      "value": "$python_dependencies",
      "data_group": "software",
      "not_show": "true"
    }
  ]
}
"@

$json_output
