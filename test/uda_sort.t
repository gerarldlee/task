#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
###############################################################################
#
# Copyright 2006 - 2015, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# http://www.opensource.org/licenses/mit-license.php
#
###############################################################################

import sys
import os
import unittest
from datetime import datetime
# Ensure python finds the local simpletap module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import Task, TestCase, Taskd, ServerTestCase


class TestUDACustomSort(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.t = Task()
        cls.t.config('uda.foo.type', 'string')
        cls.t.config('uda.foo.label', 'Foo')
        cls.t.config('uda.foo.values', 'H,M,L,')
        cls.t.config('report.list.columns', 'id,description,foo')
        cls.t.config('report.list.labels', 'ID,Desc,Foo')
        cls.t(('add', 'four',  'foo:H'))
        cls.t(('add', 'three', 'foo:M'))
        cls.t(('add', 'two',   'foo:L'))
        cls.t(('add', 'one'))

    def test_ascending(self):
        """Ascending sort order"""
        self.t.config('uda.foo.values', 'H,M,L,')
        code, out, err = self.t(('rc.report.list.sort:foo+', 'list'))

        one   = out.find('one')
        two   = out.find('two')
        three = out.find('three')
        four  = out.find('four')

        self.assertEqual(one   < two,   True)
        self.assertEqual(two   < three, True)
        self.assertEqual(three < four,  True)

    def test_descending(self):
        """Descending sort order"""
        self.t.config('uda.foo.values', 'H,M,L,')
        code, out, err = self.t(('rc.report.list.sort:foo-', 'list'))

        one   = out.find('one')
        two   = out.find('two')
        three = out.find('three')
        four  = out.find('four')

        self.assertEqual(four  < three, True)
        self.assertEqual(three < two,   True)
        self.assertEqual(two   < one,   True)

    def test_ridiculous(self):
        """Ridiculous sort order"""
        self.t.config('uda.foo.values', 'H,M,,L')
        code, out, err = self.t(('rc.report.list.sort:foo-', 'list'))

        one   = out.find('one')
        two   = out.find('two')
        three = out.find('three')
        four  = out.find('four')

        self.assertEqual(four  < three, True)
        self.assertEqual(three < one,   True)
        self.assertEqual(one   < two,   True)

if __name__ == "__main__":
    from simpletap import TAPTestRunner
    unittest.main(testRunner=TAPTestRunner())

# vim: ai sts=4 et sw=4
