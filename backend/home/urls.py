from django.urls import path
from . import views

# list of url paths corresponding to the api view to show.
urlpatterns = [
    path('api/city/<id>', views.CityView.as_view() ),
    path('api/city/', views.CityViewList.as_view() ),

    path('api/activities/', views.ActivityList.as_view() ),
    path('api/activities/<id>', views.ActivityView.as_view()),
    path('api/completed-activities/', views.CompletedActivityList.as_view() ),
    path('api/save-completed-activity/', views.CompletedActivityCreator.as_view() ),

    path('api/saved-activities/', views.SavedActivitiesList.as_view() ),
    path('api/saved-activity/<id>', views.SavedActivityView.as_view() ),
    path('api/save-saved-activity/', views.SavedActivityCreator.as_view() ),

    path('api/rewards/', views.RewardList.as_view() ),
    path('api/rewards/<id>', views.RewardView.as_view() ),

    path('api/businesses/', views.BusinessList.as_view() ),
    path('api/businesses/<id>', views.BusinessView.as_view() ),

    path('api/user/<id>', views.UserView.as_view() ),
    path('api/saved-per-user/<id>', views.get_saved_activities_formatted),
    path('api/points-per-city/<id>', views.get_points_formatted),

]
