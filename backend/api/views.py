from rest_framework import generics
from api.models import Todo

from api.serializers import TodoSerializer
from rest_framework import generics
from .serializers import TodoSerializer

# Create your views here.
#  GET POST UPDTE DELETE 

class TodoGetCreate(generics.ListCreateAPIView):
    queryset = Todo.objects.all()
    serializer_class = TodoSerializer


class TodoUpdateDelete(generics.RetrieveUpdateDestroyAPIView):
    queryset = Todo.objects.all()
    serializer_class = TodoSerializer



