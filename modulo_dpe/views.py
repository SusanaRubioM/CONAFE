from django.shortcuts import render
from login_app.decorators import role_required
from django.contrib.auth.decorators import login_required
from django.db import connection
import matplotlib.pyplot as plt
from io import BytesIO
import base64
from django.http import JsonResponse
from django.db import connection


@login_required
@role_required("DPE")
def view_home_dpe(request):
    return render(request, 'home_dpe/home_dpe.html')

@login_required
@role_required("DPE")
def dashboard_vacantes_dpe(request):
    return render(request, 'home_dpe/dashboard_vacantes_dpe.html')



#================================================================================================================================================================================
from django.db import connection
from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from login_app.decorators import role_required
import matplotlib.pyplot as plt
from io import BytesIO
import base64

@login_required
@role_required("DPE")
def estadisticas_dashboard(request):
    # Estadísticas de alumnos atendidos por Educadores Comunitarios (EC)
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT a.estado, a.nivelEducativo, COUNT(*) as total
            FROM alumnos a
            GROUP BY a.estado, a.nivelEducativo
        """)
        alumnos_data = cursor.fetchall()

    if alumnos_data:
        estados, niveles, totales = zip(*alumnos_data)

        # Gráfico 1: Distribución de alumnos por estado y nivel educativo
        fig, ax = plt.subplots(figsize=(10, 6))
        scatter = ax.scatter(estados, totales, c=[nivel for nivel in niveles], cmap="viridis", label=niveles)
        ax.set_title("Distribución de alumnos por estado y nivel educativo")
        ax.set_xlabel("Estado")
        ax.set_ylabel("Cantidad de alumnos")
        plt.xticks(rotation=45)
        plt.legend(*scatter.legend_elements(), title="Nivel Educativo")

        # Convertir gráfico a base64
        buffer = BytesIO()
        plt.savefig(buffer, format='png')
        buffer.seek(0)
        graphic1_base64 = base64.b64encode(buffer.read()).decode('utf-8')
        buffer.close()
    else:
        graphic1_base64 = None

    # Estadísticas adicionales: Total de alumnos y los que aprobaron
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                COUNT(*) as total_alumnos,
                SUM(CASE WHEN a.certificadoEstudios = 1 THEN 1 ELSE 0 END) as total_aprobados
            FROM alumnos a
        """)
        estadisticas_adicionales = cursor.fetchone()
        total_alumnos, total_aprobados = estadisticas_adicionales

    # Manejo de valores nulos para evitar errores en el gráfico
    total_alumnos = total_alumnos if total_alumnos is not None else 0
    total_aprobados = total_aprobados if total_aprobados is not None else 0

    # Gráfico 2: Comparativa de alumnos totales vs aprobados
    fig2, ax2 = plt.subplots(figsize=(8, 5))
    labels = ['Total Alumnos', 'Aprobados']
    values = [total_alumnos, total_aprobados]
    ax2.bar(labels, values, color=['skyblue', 'green'])
    ax2.set_title("Alumnos Totales vs Aprobados")
    ax2.set_ylabel("Cantidad de alumnos")

    # Convertir gráfico a base64
    buffer = BytesIO()
    plt.savefig(buffer, format='png')
    buffer.seek(0)
    graphic2_base64 = base64.b64encode(buffer.read()).decode('utf-8')
    buffer.close()

    # Renderizar en el template
    return render(request, 'estadisticas_dpe.html', {
        'graphic1': graphic1_base64,
        'graphic2': graphic2_base64,
    })
