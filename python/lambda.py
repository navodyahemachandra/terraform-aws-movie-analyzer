import json
import pandas as pd

def lambda_handler(event, context):
    try:
        # Extract the JSON payload from the POST request
        request_body = event['body']
        movies = json.loads(request_body)['movies']

        # Convert the list of dictionaries to a pandas DataFrame
        df = pd.DataFrame(movies)

        # Calculate the average rating of the movies
        average_rating = df['rating'].mean()

        # Find the director who directed the most number of movies
        director_with_most_movies = df['director'].value_counts().idxmax()

        # Create a new DataFrame with movies having rating above the average rating
        movies_above_average_df = df[df['rating'] > average_rating]

        # Convert the DataFrame to a list of dictionaries
        movies_above_average_list = movies_above_average_df.to_dict(orient='records')

        # Create the response dictionary
        response = {
            "average_rating": average_rating,
            "director_with_most_movies": director_with_most_movies,
            "movies_above_average_rating": movies_above_average_list
        }

        # Return the response with proper formatting for API Gateway
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(response)
        }

    except Exception as e:
        # Return an error response if there's an issue with processing the input
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": str(e)})
        }
