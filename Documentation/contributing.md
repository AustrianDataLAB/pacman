Contributing
============

Pacman is a sample application used with didactic intent. It's stable and consists of 
a single protected main branch. New features or bug fixes are done by creating a
short lived branch and then opening up a pull request on the public repository.
Beyond that, it is very important to sign your commits and link them directly to
issues whenever possible.

The following paragraphs offer a brief overview of the types of workflows that
have been used previously during the development process. The hope here is that
you gain some insight into why we ended up with the current model for the pacman
repository. Links are provided to some essential reading about branching and
merging with git. The final section provides some insights and motivations into
the style and usage patterns that are commonly found in successful and long-lived 
software projects that use git. 

# A history of histories

The documentation and cleanup efforts on the pacman repository in late 2022 and
early 2023 started by using the branching model suggested by  Christian Veigl in the
[Development Process](https://colab.tuwien.ac.at/display/ADLS/Development+Process) 
wiki page. In that document it is suggested that the team follow the
[Gitflow](https://nvie.com/posts/a-successful-git-branching-model/) model.
The blog post describing gitflow is well written and worth a read. However, as
the author himself notes, it was written over 10 years ago for a specific type 
of software -- desktop or mobile applications that need to maintain releases for
multiple architectures and platforms. Web applications by contrast are
continuously deployed and have the luxury of targeting a single architecture and
platform. As pacman is clearly a web application specifically designed to run on
Kubernetes, it makes more sense to follow a pattern similar to the one explained
in [Github Flow](https://docs.github.com/en/get-started/quickstart/github-flow).

# Branching and merging 

In a nutshell, the pattern advocated by Github Flow revolves around short lived
feature branches that are merged into main once they have been reviewed by a
maintainer during a merge. Essential reading for understanding how branching and
merging can be found in [section 3.2](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
of the git-scm book.

# History is not over 

If the last few years have taught us anything, it's that the assumption that we've
reached the end of history is incorrect. Although that comment is mostly
directed at world history and the assumptions made by western democracies at the
end of the soviet era, it represents a true fact about the world. We want and
need all the practice we can get being more conscious and aware of our actions
at any given moment. One of the most enjoyable coincidences of using git is that 
it gives you an opportunity to do just that -- you (literally) write history!
With that in mind, there are a few common sense guides to actually writing git
commits that I find very useful, both are blog posts. 

The first is by [Greg Hurrel](https://wincent.com/blog/commit-messages) where he
does an analysis of his own git usage and reviews the types of commits that he
has himself made over the years. 

The second is a post by lbrady titled [Writing better commit messages](http://lbrandy.com/blog/2009/03/writing-better-commit-messages/)

While those blog posts offer a good starting point and provide many useful
insights into the practice of writing git commit messages, it's also essential
to familiarize yourself with the tools required for some of the more involved
git tasks like [Rewriting history](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History)
or using [Git rebase](https://git-rebase.io/) to consolidate your feature branch
before opening up a merge request.
