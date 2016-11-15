# Onboarding Survey - Functional Specification

This is a high-level functional specification of the onboarding survey in the
Abroader web app. To see when this doc was last
updated, look at its git history.

This document is **not**:

- A technical description of the app's inner workings.
- An exhaustive description of every last little feature
- A description of how users sign in to, sign up to, or sign out from the app.
- A description of any of the app's functionality for users who have already
  completed the onboarding survey.
- At the time of writing, complete.

This doc was written by George, Abroaders CTO. If you have any questions, get
in touch with him on Slack or by [email](mailto:george@abroaders.com).

## Overview

When a user signs up to Abroaders, before they or we can do anything they need
to give us some basic information about themselves, their finances, their
existing credit cards and frequent flyer balances, etc. To accomplish this, the
first thing a user sees upon signing up is the 'Onboarding Survey', a series of
pages they must work their way through in a fixed order answering questions on
each page. The answers to earlier questions determine whether or not they will
be asked certain later questions. Until they have completed the entire
onboarding survey, they can not access any other feature of the app.

The onboarding survey contains the following pages. Not every page will
necessarily be seen by every user:

1. The 'home airports' survey
1. The 'travel plans' survey
1. The 'regions of interest' survey
1. The 'account type' survey
1. The 'eligiblity' survey
1. The 'cards' survey for the account owner
1. The 'balances' survey for the account owner
1. The 'cards' survey for the account companion
1. The 'balances' survey for the account companion
1. The 'spending' survey
1. The 'readiness' survey
1. The 'phone number' survey

Once a user has completed all relevant survey pages, they are considered
to be 'onboarded'.

Important note: an onboarded user must ONLY be able to visit their 'current'
survey page (i.e. the page in the survey that follows on from the page they
most recently completed.) Trying to visit any page other than your current
survey page should redirect you to that current page. Similarly, if you sign out
and sign back in again, the page you see immediately after sign in should
be your current survey page.

The exceptions to the 'no pages accessible except your current survey page'
rule are: basic 'account' pages such as those related to updating your
password, email, settings etc; the ability to sign out, and any pages that are
accessible even if you're not logged in at all such as our Terms and Conditions
and Privacy Policy.

And now for a functional description of each page:

## 'Home airports' survey

TODO expand

## 'Travel plans' survey

TODO expand

## 'Regions of interest' survey

TODO expand

## 'Account type' survey

TODO expand

## 'Eligiblity' survey

TODO expand

## 'Cards' survey for the account owner

TODO expand

## 'Balances' survey for the account owner

TODO expand

## 'Cards' survey for the account companion

TODO expand

## 'Balances' survey for the account companion

TODO expand

## 'Spending' survey

TODO expand

## 'Readiness' survey

TODO expand

## 'Phone number' survey

