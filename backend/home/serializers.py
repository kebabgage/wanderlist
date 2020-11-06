from rest_framework import serializers
from .models import *




# class SuburbSerializer(serializers.ModelSerializer):

#     class Meta:
#         model = Suburb
#         fields = '__all__'


class CitySerializer(serializers.ModelSerializer):

    class Meta:
        model = City
        fields = '__all__'


class ActivitySerializer(serializers.ModelSerializer):

    class Meta:
        model = Activity
        fields = '__all__'


class SavedActivitySerializer(serializers.ModelSerializer):

    class Meta:
        model = SavedActivity
        fields = '__all__'
        depth = 4 # Extra depth field to have nested JSON queries


class SavedActivitySerializer2(serializers.ModelSerializer):
    """ Specific serializer only used for creating saved activities """

    class Meta:
        model = SavedActivity
        fields = '__all__'
        

class CompletedActivitySerializer(serializers.ModelSerializer):
    

    class Meta:
        model = CompletedActivity
        fields = '__all__'
        depth = 4 # Extra depth field to have nested JSON queries


class CompletedActivitySerializer2(serializers.ModelSerializer):
    """ Specific serializer only used for creating completed activities """

    class Meta:
        model = CompletedActivity
        fields = '__all__'


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = '__all__'


class RewardSerializer(serializers.ModelSerializer):

    class Meta:
        model = Reward
        fields = '__all__'


class BusinessSerializer(serializers.ModelSerializer):

    class Meta:
        model = Business
        fields = '__all__'
