# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       tweetian

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    My SailfishOS Application
Version:    0.1
Release:    1
Group:      Qt/Qt
License:    LICENSE
Source0:    %{name}-%{version}.tar.bz2
Source100:  tweetian.yaml
Requires:   sailfishsilica-qt5
Requires:   qt5-qtdeclarative-import-location
Requires:   qt5-qtdeclarative-import-positioning
Requires:   qt5-qtsvg
Requires:   qt5-plugin-imageformat-gif
Requires:   qt5-qtsvg-plugin-imageformat-svg
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(sailfishapp)
BuildRequires:  qt5-qtdeclarative-import-location
BuildRequires:  qt5-qtdeclarative-import-positioning
BuildRequires:  qt5-qtlocation-devel
BuildRequires:  qt5-qtpositioning-devel
BuildRequires:  desktop-file-utils

%description
Short description of my SailfishOS Application


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
/usr/share/applications
/usr/share/tweetian
/usr/bin
%{_datadir}/applications/%{name}.desktop
%{_datadir}/%{name}/qml
%{_bindir}
# >> files
# << files
