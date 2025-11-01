# Verificar qué módulos Staff existen
IO.puts "=== DIAGNÓSTICO STAFF MODULE ==="

# Intentar cargar Staff de diferentes formas
try do
  IO.puts "1. Intentando Laura.Accounts.Staff..."
  alias Laura.Accounts.Staff
  IO.puts "✅ Laura.Accounts.Staff cargado: #{inspect Staff.__info__(:functions) |> length} funciones"
rescue
  e -> IO.puts "❌ Laura.Accounts.Staff NO cargado: #{inspect e}"
end

try do
  IO.puts "2. Intentando Staff directamente..."
  IO.puts "Staff module info: #{inspect Staff.__info__(:module)}"
rescue
  e -> IO.puts "❌ Staff directo NO funciona: #{inspect e}"
end

# Verificar si el archivo existe
staff_file = "lib/laura/accounts/staff.ex"
if File.exists?(staff_file) do
  IO.puts "✅ Archivo staff.ex existe"
  IO.puts "   Tamaño: #{File.stat!(staff_file).size} bytes"
else
  IO.puts "❌ Archivo staff.ex NO existe"
end

IO.puts "=== FIN DIAGNÓSTICO ==="
