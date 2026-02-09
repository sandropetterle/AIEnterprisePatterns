'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { Pencil, Trash2 } from 'lucide-react'

type PatternActionsProps = {
  slug: string
}

export function PatternActions({ slug }: PatternActionsProps) {
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)

  const handleDelete = () => {
    // In Phase 2, this will call the backend API:
    // await fetch(`/api/patterns/${slug}`, { method: 'DELETE' })
    // router.push('/patterns')
    setShowDeleteConfirm(false)
  }

  return (
    <>
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" asChild>
          <Link href={`/patterns/${slug}/edit`}>
            <Pencil className="h-4 w-4 mr-2" />
            Edit
          </Link>
        </Button>

        <Button
          variant="outline"
          size="sm"
          className="text-destructive hover:text-destructive"
          onClick={() => setShowDeleteConfirm(true)}
        >
          <Trash2 className="h-4 w-4 mr-2" />
          Delete
        </Button>
      </div>

      <Sheet open={showDeleteConfirm} onOpenChange={setShowDeleteConfirm}>
        <SheetContent side="bottom" className="sm:max-w-md sm:mx-auto">
          <SheetHeader>
            <SheetTitle>Delete Pattern?</SheetTitle>
            <SheetDescription>
              This action cannot be undone. This will permanently delete the
              pattern.
            </SheetDescription>
          </SheetHeader>
          <div className="flex gap-3 mt-6">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => setShowDeleteConfirm(false)}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              className="flex-1"
              onClick={handleDelete}
            >
              Delete
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </>
  )
}
