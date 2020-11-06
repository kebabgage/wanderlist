""" This file contains the models for our Databse """

from django.db import models
from django.utils import timezone


class City(models.Model):
    """ A class representing a city in our database """
    name = models.CharField(max_length=40)

    def __str__(self):
        return self.name


class Business(models.Model):
    """ A class representing a business in our database """
    name = models.CharField(max_length=40)
    city = models.ForeignKey(City, on_delete=models.CASCADE, null=True, blank=True)
    address = models.CharField(max_length=50)

    def __str__(self):
        return self.name


class Activity(models.Model):
    """ A class representing an activity in our database """
    name = models.CharField(max_length=40)
    description = models.TextField(blank=True, default="")

    city = models.ForeignKey(City, on_delete=models.CASCADE, null=True, blank=True)
    address = models.CharField(max_length=40)
    code = models.CharField(max_length=20)
    points = models.IntegerField()

    def __str__(self):
        return self.name


class User(models.Model):
    """ A class representing a user in our database """
    name = models.CharField(max_length=40)
    email = models.EmailField()
    points = models.IntegerField(default=0)
    mobile = models.CharField(max_length=20)

    def __str__(self):
        return self.email


class SavedActivity(models.Model):
    """ A class representing a saved activity in our database """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    activity = models.ForeignKey(Activity, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.user.name}: {self.activity.name}"


class CompletedActivity(models.Model):
    """ A class representing a completed activity in our database """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    activity = models.ForeignKey(Activity, on_delete=models.CASCADE)
    time = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.user.name}: {self.activity.name}"


class Reward(models.Model):
    """ A class representing a reward in our database """
    name = models.CharField(max_length=40)
    count = models.IntegerField(default=10)
    points = models.IntegerField(default=50)
    expires = models.DateTimeField()
    business = models.ForeignKey(Business, on_delete=models.CASCADE)
    description = models.TextField(blank=True)

    def __str__(self):
        return f"{self.business.name}: {self.name} ({self.count})"


