from django.shortcuts import render

def visualizar_calendario(request):
    return render(request, 'modulo_calendario/visualizar_calendario.html')

def historial_calendario(request):
    return render(request, 'modulo_calendario/historial_calendario.html')
