from django.shortcuts import render
from .serializers import *
from .models import *

from django.http import JsonResponse

from rest_framework import generics
from django_filters import rest_framework as filters
from django.core import serializers

def get_saved_activities_formatted(request, id):
    """ Attempts to pull saved activities in a per city per user format

    Parameters:
        request: The django http request object
        id (int): The id corresponding to the user to filter

    Returns:
        (JsonResponse): The json for the formatted saved activities

    """
    result = {}
    saved = SavedActivity.objects.select_related('activity').filter(id=id)

    for saved_activity in saved:
        city = City.objects.get(id=saved_activity.activity.city.id)
        result.setdefault(city.name, list()).append(saved_activity)

    for city in result:
        result[city] = serializers.serialize('json', result[city])

    return JsonResponse(result)

def get_points_formatted(request, id):
    """ Pulls the points per city for a specified user

    Parameters:
        request: The django http request object
        id (int): The id corresponding to the user to filter

    Returns:
        (JsonResponse): The json for the formatted points
    """
    result = {}
    completed = CompletedActivity.select_related('activity').filter(id=id)

    for completed_activity in completed:
        city = City.objects.get(id=completed_activity.city__id)
        result[city.id] = result.setdefault(city.id, 0) + completed_activity.activity.points

    return JsonResponse(result)

# City
class CityView(generics.RetrieveAPIView):
    """ View for pulling info about a specific city """
    serializer_class = CitySerializer
    queryset = City.objects.all()
    lookup_field = 'id'


class CityViewList(generics.ListCreateAPIView):
    """ View for pulling info about all cities """
    serializer_class = CitySerializer
    queryset = City.objects.all()


# Activities
class ActivityList(generics.ListCreateAPIView):
    """ View for pulling info about all activities """
    serializer_class = ActivitySerializer
    queryset = Activity.objects.all()


class ActivityView(generics.RetrieveAPIView):
    """ View for pulling info about a specific activity """
    serializer_class = ActivitySerializer
    queryset = Activity.objects.all()
    lookup_field = 'id'


# Completed Activities
class CompletedActivityList(generics.ListCreateAPIView):    
    """ View for pulling info about all completed activities """
    serializer_class = CompletedActivitySerializer
    queryset = CompletedActivity.objects.all()
    filter_backends = (filters.DjangoFilterBackend,)
    filter_fields = ('user__id',)


class CompletedActivityCreator(generics.CreateAPIView):
    """ View for pulling info about a specific completed activity """
    serializer_class = CompletedActivitySerializer2
    queryset = CompletedActivity.objects.all()


# Saved Activities
class SavedActivitiesList(generics.ListCreateAPIView):
    """ View for pulling info about all saved activities """
    serializer_class = SavedActivitySerializer
    queryset = SavedActivity.objects.all()
    filter_backends = (filters.DjangoFilterBackend,)
    filter_fields = ('user__id',)


class SavedActivityCreator(generics.CreateAPIView):
    """ View for creating a new activity"""
    serializer_class = SavedActivitySerializer2
    queryset = SavedActivity.objects.all()


class SavedActivityView(generics.RetrieveDestroyAPIView):
    """ View for pulling info about a specific completed activity. Also supports deleting """
    serializer_class = SavedActivitySerializer
    queryset = SavedActivity.objects.all()
    lookup_field = 'id'


# Businesses
class BusinessList(generics.ListAPIView):
    """ View for pulling info about all businesses """
    queryset = Business.objects.all()
    serializer_class = BusinessSerializer


class BusinessView(generics.RetrieveDestroyAPIView):
    """ View for pulling info about a specific business """
    serializer_class = BusinessSerializer
    queryset = Business.objects.all()
    lookup_field = 'id'


# Rewards
class RewardList(generics.ListAPIView):
    """ View for pulling info about all rewards """
    serializer_class = RewardSerializer
    queryset = Reward.objects.all()
    filter_backends = (filters.DjangoFilterBackend,)
    filter_fields = ('business__id',)


class RewardView(generics.RetrieveUpdateAPIView):
    """ View for pulling info about a specific reward """
    serializer_class = RewardSerializer
    queryset = Reward.objects.all()
    lookup_field = 'id'


# User
class UserView(generics.RetrieveUpdateAPIView):
    """ View for pulling info about a specific user """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    lookup_field = 'id'
