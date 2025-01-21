from django.shortcuts import render

def asignar_pagos(request):
    return render(request, 'modulo_pagos/asignar_pagos.html')

def historial_pagos(request):
    return render(request, 'modulo_pagos/historial_pagos.html')
