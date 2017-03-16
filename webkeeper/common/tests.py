# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import TestCase

from common.models import NavItems

# Create your tests here.


class NavItemsTestCase(TestCase):
    fixtures = ['nav_items.json']

    def test_get_menu_data(self):
        result = NavItems.get_menu_data()
        assert len(result) == 2
