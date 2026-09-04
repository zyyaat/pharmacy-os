import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: Date | string): string {
  const d = new Date(date);
  return new Intl.DateTimeFormat("ar-EG", {
    year: "numeric",
    month: "long",
    day: "numeric",
  }).format(d);
}

export function formatDateTime(date: Date | string): string {
  const d = new Date(date);
  return new Intl.DateTimeFormat("ar-EG", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(d);
}

export const PERMISSIONS = {
  // Company Permissions
  COMPANIES_VIEW: "companies.view",
  COMPANIES_CREATE: "companies.create",
  COMPANIES_EDIT: "companies.edit",
  COMPANIES_DELETE: "companies.delete",
  
  // Company Users Permissions
  COMPANY_USERS_VIEW: "company_users.view",
  COMPANY_USERS_CREATE: "company_users.create",
  COMPANY_USERS_EDIT: "company_users.edit",
  COMPANY_USERS_DELETE: "company_users.delete",
  COMPANY_USERS_MANAGE_PERMISSIONS: "company_users.manage_permissions",
  
  // Accounts Permissions
  ACCOUNTS_VIEW: "accounts.view",
  ACCOUNTS_CREATE: "accounts.create",
  ACCOUNTS_EDIT: "accounts.edit",
  ACCOUNTS_DELETE: "accounts.delete",
  
  // Platform Permissions
  PLATFORM_SETTINGS: "platform.settings",
  PLATFORM_MANAGEMENT: "platform.management",
  PLATFORM_ANALYTICS: "platform.analytics",
} as const;

export type Permission = (typeof PERMISSIONS)[keyof typeof PERMISSIONS];

export const ROLES = {
  SUPER_ADMIN: "super_admin",
  COMPANY_ADMIN: "company_admin",
  COMPANY_MANAGER: "company_manager",
  VIEWER: "viewer",
} as const;

export type Role = (typeof ROLES)[keyof typeof ROLES];

export const ROLE_LABELS: Record<Role, string> = {
  [ROLES.SUPER_ADMIN]: "مدير النظام",
  [ROLES.COMPANY_ADMIN]: "مدير الشركة",
  [ROLES.COMPANY_MANAGER]: "مدير العمليات",
  [ROLES.VIEWER]: "مشاهد",
};

export const PERMISSION_LABELS: Record<Permission, string> = {
  [PERMISSIONS.COMPANIES_VIEW]: "عرض الشركات",
  [PERMISSIONS.COMPANIES_CREATE]: "إنشاء شركة",
  [PERMISSIONS.COMPANIES_EDIT]: "تعديل شركة",
  [PERMISSIONS.COMPANIES_DELETE]: "حذف شركة",
  [PERMISSIONS.COMPANY_USERS_VIEW]: "عرض المستخدمين",
  [PERMISSIONS.COMPANY_USERS_CREATE]: "إنشاء مستخدم",
  [PERMISSIONS.COMPANY_USERS_EDIT]: "تعديل مستخدم",
  [PERMISSIONS.COMPANY_USERS_DELETE]: "حذف مستخدم",
  [PERMISSIONS.COMPANY_USERS_MANAGE_PERMISSIONS]: "إدارة الصلاحيات",
  [PERMISSIONS.ACCOUNTS_VIEW]: "عرض الحسابات",
  [PERMISSIONS.ACCOUNTS_CREATE]: "إنشاء حساب",
  [PERMISSIONS.ACCOUNTS_EDIT]: "تعديل حساب",
  [PERMISSIONS.ACCOUNTS_DELETE]: "حذف حساب",
  [PERMISSIONS.PLATFORM_SETTINGS]: "إعدادات المنصة",
  [PERMISSIONS.PLATFORM_MANAGEMENT]: "إدارة المنصة",
  [PERMISSIONS.PLATFORM_ANALYTICS]: "تحليلات المنصة",
};
