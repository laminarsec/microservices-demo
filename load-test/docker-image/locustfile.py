import base64

from locust import HttpUser, TaskSet, task, between
from random import choice


class WebTasks(TaskSet):
    USERNAME = "user"
    PASSWORD = "password"
    wait_time = between(0, 1.5)

    def _get_auth(self) -> str:
        auth = f'{self.USERNAME}:{self.PASSWORD}'.encode()
        base64auth = base64.encodebytes(auth)
        return base64auth.decode().replace('\n', '')

    @task
    def load(self):
        catalogue = self.client.get("/catalogue").json()
        category_item = choice(catalogue)
        item_id = category_item["id"]

        self.client.get("/category.html")
        self.client.get("/detail.html?id={}".format(item_id))
        self.client.delete("/cart")
        self.client.post("/cart", json={"id": item_id, "quantity": 1})
        self.client.get("/basket.html")
        self.client.post("/orders")

    def on_start(self):
        self.client.get("/")
        self.client.get("/login", headers={"Authorization":"Basic %s" % self._get_auth()})


class Web(HttpUser):
    tasks = [WebTasks]
