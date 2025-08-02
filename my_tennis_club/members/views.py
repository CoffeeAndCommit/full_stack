from django import template
from django.http import HttpResponse
from django.template import loader
from .models import Member

def members(request):
  members = Member.objects.all().values()
  template = loader.get_template('all_members.html')
  context = {
    'mymembers': members,
  }
  return HttpResponse(template.render(context, request))

def details(request, id):
  mymember = Member.objects.get(id=id)
  template = loader.get_template('details.html')
  context = {
    'mymember': mymember,
  }
  return HttpResponse(template.render(context, request))

def main(request):
  template = loader.get_template('main.html')
  return HttpResponse(template.render())



def testing(request):
  mymembers = Member.objects.all().values()
  template = loader.get_template('template.html')
  context = {
   'mymembers':mymembers,
  }
  return HttpResponse(template.render(context, request))


# filter query set from member data base


def first_name(request):
  mymembers = Member.objects.filter(firstname__startswith='L').values() 
  template = loader.get_template('template.html')
  context = {
   'mymembers':mymembers,
  }
  return HttpResponse(template.render(context, request))


def order_by(request):
  mymembers = Member.objects.order_by('firstname').values()
  template= loader.get_template('order_by.html')
  context = {
    'mymembers':mymembers,
  }
  return HttpResponse(template.render(context, request))